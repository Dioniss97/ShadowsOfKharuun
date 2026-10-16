"""Bake the three Vigía materials and export a self-contained Godot GLB.

The editable source keeps separate named parts and procedural stone/bronze.
Only temporary export copies are joined, UV-unwrapped, baked and triangulated.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from math import pi, radians
from pathlib import Path
import struct
import sys

import bmesh
import bpy


ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "art/source/statues/vigia_umbral.blend"
OUTPUT = ROOT / "assets/models/environment/vigia_umbral.glb"
MAP_DIR = ROOT / "art/source/statues/vigia_umbral_textures"
REPORT = ROOT / "art/references/vigia_umbral/export_report.json"
MATERIALS = ["Basalto_Gris_Desgastado", "Piedra_Clara_Mate", "Bronce_Envejecido"]
ATLAS_REPAIRS = {}


def select_only(objects):
    bpy.ops.object.select_all(action="DESELECT")
    for obj in objects:
        obj.hide_set(False)
        obj.select_set(True)
    bpy.context.view_layer.objects.active = objects[0]


def export_meshes(source_objects, target_collection):
    depsgraph = bpy.context.evaluated_depsgraph_get()
    groups = {name: [] for name in MATERIALS}
    for source in source_objects:
        if source.type != "MESH":
            continue
        mesh = bpy.data.meshes.new_from_object(source.evaluated_get(depsgraph),
                   preserve_all_data_layers=True, depsgraph=depsgraph)
        if len(mesh.materials) != 1 or mesh.materials[0].name not in groups:
            raise RuntimeError(f"Material inesperado en {source.name}")
        if mesh.materials[0].name == MATERIALS[0] and mesh.color_attributes.get("Vigia_Pigment") is None:
            mask = mesh.color_attributes.new(name="Vigia_Pigment",type="FLOAT_COLOR",domain="CORNER")
            mask.data.foreach_set("color",[0,0,0,1]*len(mesh.loops))
        obj = bpy.data.objects.new("Export_" + source.name, mesh)
        target_collection.objects.link(obj)
        obj.matrix_world = source.matrix_world.copy()
        groups[mesh.materials[0].name].append(obj)
    result = []
    for name, objects in groups.items():
        if not objects:
            raise RuntimeError(f"Falta el grupo de material {name}")
        select_only(objects)
        bpy.ops.object.join()
        obj = bpy.context.object
        obj.name = name + "_GLTF"
        bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
        # Collapse duplicate slots created by join before baking one atlas per material.
        mat = bpy.data.materials[name]
        obj.data.materials.clear()
        obj.data.materials.append(mat)
        for poly in obj.data.polygons:
            poly.material_index = 0
        triangulate = obj.modifiers.new("Triangulación exportable", "TRIANGULATE")
        bpy.ops.object.modifier_apply(modifier=triangulate.name)
        bm = bmesh.new()
        bm.from_mesh(obj.data)
        before_faces = len(bm.faces)
        # Preserve the thin engraved glyph faces and their corner masks.
        # A 0.1mm cleanup can collapse sliver triangles carrying the pigment.
        bmesh.ops.remove_doubles(bm, verts=list(bm.verts), dist=0.000001)
        bmesh.ops.dissolve_degenerate(bm, edges=list(bm.edges), dist=0.00000001)
        bmesh.ops.triangulate(bm, faces=list(bm.faces))
        bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces))
        print(f"LIMPIEZA_MALLA {name}: {before_faces} -> {len(bm.faces)} caras", flush=True)
        bm.to_mesh(obj.data)
        bm.free()
        obj.data.update()
        bpy.ops.object.mode_set(mode="EDIT")
        bpy.ops.mesh.select_all(action="SELECT")
        bpy.ops.uv.smart_project(angle_limit=radians(66), island_margin=0.008)
        bpy.ops.object.mode_set(mode="OBJECT")
        if name == MATERIALS[0]:
            stole_uv(obj)
        result.append(obj)
    return result


def stole_uv(obj):
    # Reserve two continuous front projections in the existing stone atlas.
    # Smart UV islands for narrow recessed strokes can be subpixel and lose
    # whole letters during baking. No larger texture or extra material needed.
    uv = obj.data.uv_layers.active.data
    mask = obj.data.color_attributes.get("Vigia_Pigment")
    for loop in uv:
        loop.uv = (.51+.48*loop.uv.x,.01+.98*loop.uv.y)
    count = 0
    for face in obj.data.polygons:
        if not (.90 <= face.center.z <= 4.25 and face.normal.y > .60):
            continue
        if max(mask.data[i].color[0] for i in face.loop_indices) < .5 and max(mask.data[i].color[1] for i in face.loop_indices) < .5:
            continue
        side = 1 if face.center.x > 0 else -1
        origin = .025 if side == 1 else .27
        for i in face.loop_indices:
            v = obj.data.vertices[obj.data.loops[i].vertex_index].co
            uv[i].uv = (origin+(side*v.x-.15)/.54*.20,.02+(v.z-.90)/3.35*.96)
        count += 1
    print(f"UV_ESTOLA_OK {count} caras con proyección continua",flush=True)


def bake(obj, resolution):
    select_only([obj])
    source_mat = obj.data.materials[0]
    nodes, links = source_mat.node_tree.nodes, source_mat.node_tree.links
    shader = nodes.get("Principled BSDF")
    output = nodes.get("Material Output")
    emission = nodes.new("ShaderNodeEmission")
    emission.inputs["Strength"].default_value = 1
    images = {}
    for channel in ("BaseColor", "Roughness", "Normal"):
        name = source_mat.name + "_" + channel
        image = bpy.data.images.new(name, width=resolution, height=resolution, alpha=False)
        image.colorspace_settings.name = "sRGB" if channel == "BaseColor" else "Non-Color"
        # Subpixel UV slivers can miss every bake sample. Leave a valid material
        # value there instead of black albedo / invalid (0,0,0) tangent normals.
        if channel == "Normal":
            fill = (0.5, 0.5, 1.0, 1.0)
        elif channel == "Roughness":
            fill = (0.85, 0.85, 0.85, 1.0)
        elif "Bronce" in source_mat.name:
            fill = (0.065, 0.070, 0.035, 1.0)
        elif "Clara" in source_mat.name:
            fill = (0.22, 0.23, 0.215, 1.0)
        else:
            fill = (0.058, 0.071, 0.082, 1.0)
        if channel == "BaseColor":
            # Generated-image fallback values are written directly to the PNG.
            # Material colours are linear; storing them as raw sRGB made missed
            # subpixel UV triangles almost black after the engine decoded them.
            fill = tuple(12.92*c if c<=.0031308 else 1.055*c**(1/2.4)-.055
                         for c in fill[:3])+(1.0,)
        image.pixels.foreach_set(fill * (resolution * resolution))
        image.update()
        target = nodes.new("ShaderNodeTexImage")
        target.image = image
        for existing in nodes:
            existing.select = False
        target.select = True
        nodes.active = target
        if channel == "Normal":
            links.new(shader.outputs["BSDF"], output.inputs["Surface"])
            bpy.ops.object.bake(type="NORMAL", normal_space="TANGENT",
                                use_clear=False, margin=12)
        else:
            source_input = shader.inputs["Base Color" if channel == "BaseColor" else "Roughness"]
            if source_input.is_linked:
                links.new(source_input.links[0].from_socket, emission.inputs["Color"])
            else:
                v = source_input.default_value
                emission.inputs["Color"].default_value = v if channel == "BaseColor" else (v, v, v, 1)
            links.new(emission.outputs[0], output.inputs["Surface"])
            bpy.ops.object.bake(type="EMIT", use_clear=False, margin=12)
        if channel == "BaseColor":
            ATLAS_REPAIRS[source_mat.name] = repair_unsampled_colour(obj,image,fill)
        image.filepath_raw = str(MAP_DIR / (name + ".png"))
        image.file_format = "PNG"
        image.save()
        images[channel] = image
        nodes.remove(target)
        print(f"MAPA_OK {name} {resolution}x{resolution}", flush=True)
    links.new(shader.outputs["BSDF"], output.inputs["Surface"])
    nodes.remove(emission)
    pbr = bpy.data.materials.new(source_mat.name + "_PBR")
    pbr.use_nodes = True
    pnodes, plinks = pbr.node_tree.nodes, pbr.node_tree.links
    bsdf = pnodes.get("Principled BSDF")
    bsdf.inputs["Metallic"].default_value = shader.inputs["Metallic"].default_value
    for channel, image in images.items():
        texture = pnodes.new("ShaderNodeTexImage")
        texture.image = image
        if channel == "Normal":
            normal = pnodes.new("ShaderNodeNormalMap")
            normal.inputs["Strength"].default_value = 0.25
            plinks.new(texture.outputs["Color"], normal.inputs["Color"])
            plinks.new(normal.outputs["Normal"], bsdf.inputs["Normal"])
        else:
            plinks.new(texture.outputs["Color"], bsdf.inputs["Base Color" if channel == "BaseColor" else "Roughness"])
    obj.data.materials.clear()
    obj.data.materials.append(pbr)
    mask = obj.data.color_attributes.get("Vigia_Pigment")
    if mask is not None:
        # Already baked in BaseColor: never multiply it again in glTF/Godot.
        obj.data.color_attributes.remove(mask)


def repair_unsampled_colour(obj,image,fill):
    """Fill missed, very thin UV faces from adjacent sampled surface colours."""
    import numpy as np
    mesh=obj.data
    size=image.size[0]
    pixels=np.empty(len(image.pixels),dtype=np.float32)
    image.pixels.foreach_get(pixels)
    pixels=pixels.reshape((size,size,4))
    coords=np.empty(len(mesh.loops)*2,dtype=np.float32)
    mesh.uv_layers.active.data.foreach_get('uv',coords)
    triangles=coords.reshape((-1,3,2))*size-.5
    edges=np.roll(triangles,-1,axis=1)-triangles
    lengths=np.linalg.norm(edges,axis=2)
    signed=(edges[:,0,0]*(-edges[:,2,1])-edges[:,0,1]*(-edges[:,2,0]))
    altitude=np.abs(signed)/np.maximum(lengths.max(axis=1),1e-12)
    centers=triangles.mean(axis=1)
    xy=np.clip(np.floor(centers+.5).astype(int),0,size-1)
    colours=pixels[xy[:,1],xy[:,0],:3].copy()
    missing=np.max(np.abs(colours-np.array(fill[:3])),axis=1)<.0025
    candidates=np.flatnonzero(missing & (altitude<1.5))
    vertex_faces=[[] for _ in mesh.vertices]
    faces=[tuple(p.vertices) for p in mesh.polygons]
    for i,verts in enumerate(faces):
        for v in verts: vertex_faces[v].append(i)
    mask=mesh.color_attributes.get('Vigia_Pigment')
    masks=np.array([tuple(np.mean([mask.data[j].color[:2] for j in p.loop_indices],axis=0))
                    for p in mesh.polygons]) if mask else np.zeros((len(faces),2))
    repaired=0
    changed=0
    for i in candidates:
        frontier={i};seen={i};samples=[]
        for _ in range(4):
            adjacent={n for f in frontier for v in faces[f] for n in vertex_faces[v]}-seen
            seen.update(adjacent)
            samples.extend(n for n in adjacent if not missing[n] and np.max(np.abs(masks[n]-masks[i]))<.15)
            if len(samples)>=3: break
            frontier=adjacent
        if not samples: continue
        colour=np.median(colours[samples],axis=0)
        tri=triangles[i]
        lower=np.maximum(0,np.floor(tri.min(axis=0)-1.5).astype(int))
        upper=np.minimum(size-1,np.ceil(tri.max(axis=0)+1.5).astype(int))
        yy,xx=np.mgrid[lower[1]:upper[1]+1,lower[0]:upper[0]+1]
        cover=np.ones(xx.shape,dtype=bool)
        orient=1 if signed[i]>=0 else -1
        for a,e,length in zip(tri,edges[i],lengths[i]):
            cover &= orient*(e[0]*(yy-a[1])-e[1]*(xx-a[0]))>=-1.2*length
        patch=pixels[lower[1]:upper[1]+1,lower[0]:upper[0]+1,:3]
        cover &= np.max(np.abs(patch-np.array(fill[:3])),axis=2)<.0025
        patch[cover]=colour
        changed+=int(cover.sum())
        repaired+=1
    image.pixels.foreach_set(pixels.ravel())
    image.update()
    result={'thin_faces':repaired,'texels':changed,'method':'Adjacent surface colour, preserving pigment masks'}
    print('ATLAS_REPAIR_OK',obj.name,result,flush=True)
    return result


def check_and_report(meshes):
    data = OUTPUT.read_bytes()
    magic, version, total = struct.unpack_from("<III", data, 0)
    if magic != 0x46546C67 or version != 2 or total != len(data):
        raise RuntimeError("Cabecera GLB inválida")
    chunk_length, chunk_type = struct.unpack_from("<II", data, 12)
    if chunk_type != 0x4E4F534A:
        raise RuntimeError("El primer bloque GLB no contiene JSON")
    gltf = json.loads(data[20:20 + chunk_length].decode("utf-8"))
    materials, images = gltf.get("materials", []), gltf.get("images", [])
    if len(materials) != 3 or len(images) != 9:
        raise RuntimeError(f"Se esperaban tres materiales/nueve mapas; recibidos {len(materials)}/{len(images)}")
    if any("bufferView" not in image or "uri" in image for image in images):
        raise RuntimeError("El GLB todavía depende de imágenes externas")
    if any(key.startswith("COLOR_") for mesh in gltf.get("meshes",[]) for p in mesh["primitives"] for key in p["attributes"]):
        raise RuntimeError("La máscara de pigmento ya horneada no debe exportarse como color de vértice")
    for mat in materials:
        if "normalTexture" not in mat or "metallicRoughnessTexture" not in mat["pbrMetallicRoughness"]:
            raise RuntimeError(f"Falta un mapa PBR en {mat['name']}")
        if any(c > 0 for c in mat.get("emissiveFactor",[0,0,0])) or "emissiveTexture" in mat:
            raise RuntimeError("El pigmento no debe emitir luz")
    report = {
        "asset": "Vigía del Umbral", "iteration": 8,
        "blender": bpy.app.version_string,
        "source": str(SOURCE.relative_to(ROOT)).replace("\\", "/"),
        "source_sha256": hashlib.sha256(SOURCE.read_bytes()).hexdigest(),
        "glb": str(OUTPUT.relative_to(ROOT)).replace("\\", "/"),
        "bytes": len(data), "sha256": hashlib.sha256(data).hexdigest(),
        "vertices": sum(len(obj.data.vertices) for obj in meshes),
        "triangles": sum(len(obj.data.polygons) for obj in meshes),
        "materials": [mat["name"] for mat in materials],
        "embedded_images": len(images),
        "normal_scales": [mat["normalTexture"].get("scale", 1.0) for mat in materials],
        "emission": False,
        "runtime_color_attributes": False,
        "stole_uv": "Two continuous front projections reserved inside the existing stone atlas",
        "atlas_repairs": ATLAS_REPAIRS,
        "pigment": "Worn red incisions and darker stole/hood lip baked into stone BaseColor; no runtime mask attribute",
        "expected_godot_front": "+Z; confirm with an actual Godot capture",
        "acceptance": "Pending human review; this report is not mission QA"
    }
    REPORT.parent.mkdir(parents=True, exist_ok=True)
    REPORT.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(json.dumps(report, ensure_ascii=False), flush=True)


def main():
    args = argparse.ArgumentParser()
    args.add_argument("--texture-size", type=int, default=2048)
    opts = args.parse_args(sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else [])
    if tuple(bpy.app.version[:3]) != (5, 2, 2):
        raise RuntimeError(f"Se necesita Blender 5.2.2; recibido {bpy.app.version_string}")
    if opts.texture_size not in (512, 1024, 2048):
        raise ValueError("--texture-size debe ser 512, 1024 o 2048")
    bpy.ops.wm.open_mainfile(filepath=str(SOURCE))
    source_collection = bpy.data.collections.get("VIGIA_MODEL")
    if source_collection is None:
        raise RuntimeError("Falta la colección VIGIA_MODEL")
    target_collection = bpy.data.collections.new("VIGIA_EXPORT")
    bpy.context.scene.collection.children.link(target_collection)
    # Keep a stable snapshot: joining temporary copies invalidates Blender's
    # cached Collection.all_objects view in some background sessions.
    source_objects = [obj for obj in source_collection.all_objects if obj is not None]
    meshes = export_meshes(source_objects, target_collection)
    for obj in source_objects:
        obj.hide_render = True
        obj.hide_set(True)
    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    scene.cycles.samples = 1
    scene.render.bake.use_selected_to_active = False
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    MAP_DIR.mkdir(parents=True, exist_ok=True)
    for index, obj in enumerate(meshes):
        resolution = max(512, opts.texture_size // (2 ** index))
        bake(obj, resolution)
    root = bpy.data.objects.new("Vigia_del_Umbral_GLTF", None)
    target_collection.objects.link(root)
    for obj in meshes:
        obj.parent = root
    # Blender +Y becomes glTF -Z. This turn makes the model face Godot +Z.
    root.rotation_euler.z = pi
    select_only([root, *meshes])
    bpy.ops.export_scene.gltf(filepath=str(OUTPUT), export_format="GLB",
        use_selection=True, export_yup=True, export_apply=False,
        export_animations=False, export_cameras=False, export_lights=False,
        export_extras=False, export_materials="EXPORT", export_skins=False,
        export_morph=False, export_tangents=True)
    check_and_report(meshes)
    print(f"GLB_OK {OUTPUT}", flush=True)


if __name__ == "__main__":
    main()
