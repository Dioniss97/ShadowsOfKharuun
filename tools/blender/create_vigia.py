"""Build the editable, hooded Vigía and render review views in Blender 5.2.2.

The sculpture faces Blender +Y. export_vigia.py bakes its three materials and
turns the export toward Godot +Z. --draft makes a quick geometry preview.
"""

from __future__ import annotations

import argparse
from math import cos, exp, pi, sin, sqrt
from pathlib import Path
import sys

import bmesh
import bpy
from mathutils import Vector
from mathutils.bvhtree import BVHTree


ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "art/source/statues/vigia_umbral.blend"
REFERENCE_DIR = ROOT / "art/references/vigia_umbral"
MODEL_COLLECTION_NAME = "VIGIA_MODEL"
MODEL_ROOT_NAME = "Vigia_del_Umbral"
MODEL = None
STUDIO = None
ANCHOR = None
TAU = 2 * pi
HAND_HEIGHTS = {-1: 4.62, 1: 4.99}  # +1 is the anatomical right, left in front views.
SWORD_DROP = 0.22


def ensure_version():
    if tuple(bpy.app.version[:3]) != (5, 2, 2):
        raise RuntimeError(f"Se necesita Blender 5.2.2; recibido {bpy.app.version_string}")


def collection(name):
    value = bpy.data.collections.new(name)
    bpy.context.scene.collection.children.link(value)
    return value


def mesh_object(name, verts, faces, material, smooth=True, wear=False):
    mesh = bpy.data.meshes.new(name + "_Mesh")
    mesh.from_pydata(verts, [], faces)
    mesh.update()
    bm = bmesh.new()
    bm.from_mesh(mesh)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    bm.to_mesh(mesh)
    bm.free()
    obj = bpy.data.objects.new(name, mesh)
    MODEL.objects.link(obj)
    obj.parent = ANCHOR
    mesh.materials.append(material)
    for poly in mesh.polygons:
        poly.use_smooth = smooth
    if wear:
        modifier = obj.modifiers.new("Desgaste leve de cantería", "DISPLACE")
        modifier.texture = bpy.data.textures.get("Stone_Wear")
        modifier.texture_coords = "GLOBAL"
        modifier.strength = 0.012
        modifier.mid_level = 0.5
    return obj


def loft(name, rings, material, closed=True, caps=True, smooth=True, wear=False):
    count = len(rings[0])
    faces = []
    for row in range(len(rings) - 1):
        for col in range(count if closed else count - 1):
            nxt = (col + 1) % count
            faces.append((row * count + col, row * count + nxt,
                          (row + 1) * count + nxt, (row + 1) * count + col))
    if caps and closed:
        faces.append(tuple(reversed(range(count))))
        faces.append(tuple((len(rings) - 1) * count + i for i in range(count)))
    return mesh_object(name, [v for ring in rings for v in ring], faces,
                       material, smooth, wear)


def solidify(obj, thickness=0.055):
    modifier = obj.modifiers.new("Espesor de piedra tallada", "SOLIDIFY")
    modifier.thickness = thickness
    modifier.offset = -0.3
    return obj


def node(nodes, kind, x, y):
    value = nodes.new(kind)
    value.location = (x, y)
    return value


def ramp(nodes, values, x, y):
    value = node(nodes, "ShaderNodeValToRGB", x, y)
    color_ramp = value.color_ramp
    color_ramp.elements.remove(color_ramp.elements[1])
    for index, (position, color) in enumerate(values):
        element = color_ramp.elements[0] if index == 0 else color_ramp.elements.new(position)
        element.position = position
        element.color = (*color, 1)
    return value


def material(name, light=False, bronze=False):
    value = bpy.data.materials.new(name)
    value.use_nodes = True
    value.diffuse_color = (0.19, 0.205, 0.21, 1) if not bronze else (0.13, 0.09, 0.045, 1)
    nodes, links = value.node_tree.nodes, value.node_tree.links
    shader = nodes.get("Principled BSDF")
    shader.location = (580, 100)
    shader.inputs["Metallic"].default_value = 0.78 if bronze else 0
    shader.inputs["Roughness"].default_value = 0.8
    tex = node(nodes, "ShaderNodeTexCoord", -1000, 50)
    tex.object = ANCHOR
    broad = node(nodes, "ShaderNodeTexNoise", -800, 320)
    broad.inputs["Scale"].default_value = 4.5 if bronze else 2.8
    broad.inputs["Detail"].default_value = 4
    broad.inputs["Roughness"].default_value = 0.68
    grain = node(nodes, "ShaderNodeTexNoise", -800, -40)
    grain.inputs["Scale"].default_value = 110 if bronze else 75
    grain.inputs["Detail"].default_value = 2.3
    grain.inputs["Roughness"].default_value = 0.7
    medium = node(nodes, "ShaderNodeTexNoise", -800, -340)
    medium.inputs["Scale"].default_value = 15
    medium.inputs["Detail"].default_value = 3
    for noise in (broad, grain, medium):
        links.new(tex.outputs["Object"], noise.inputs["Vector"])
    if bronze:
        colors = [(0.15, (0.025, 0.025, 0.017)), (0.43, (0.105, 0.070, 0.028)),
                  (0.60, (0.055, 0.078, 0.052)), (0.78, (0.035, 0.085, 0.068))]
    elif light:
        colors = [(0.15, (0.12, 0.13, 0.12)), (0.5, (0.22, 0.23, 0.215)),
                  (0.82, (0.30, 0.31, 0.285))]
    else:
        colors = [(0.12, (0.026, 0.033, 0.041)), (0.48, (0.058, 0.071, 0.082)),
                  (0.85, (0.11, 0.125, 0.13))]
    color = ramp(nodes, colors, -530, 340)
    links.new(broad.outputs["Fac"], color.inputs["Fac"])
    links.new(color.outputs["Color"], shader.inputs["Base Color"])
    if not light and not bronze:
        # Two face-corner masks share the stone material. The exporter bakes
        # them into its existing maps; no extra runtime material is needed.
        attribute = node(nodes,"ShaderNodeAttribute",-780,650)
        attribute.attribute_name = "Vigia_Pigment"
        masks = node(nodes,"ShaderNodeSeparateXYZ",-570,650)
        links.new(attribute.outputs["Color"],masks.inputs["Vector"])
        dark = node(nodes,"ShaderNodeMixRGB",-290,550)
        dark.blend_type = "MULTIPLY"
        dark.inputs[2].default_value = (.32,.32,.32,1)
        links.new(masks.outputs["X"],dark.inputs[0])
        links.new(color.outputs["Color"],dark.inputs[1])
        red = ramp(nodes,[(.18,(.10,.012,.009)),(.45,(.34,.028,.019)),
                         (.78,(.48,.058,.032))],-530,850)
        links.new(medium.outputs["Fac"],red.inputs["Fac"])
        wear = ramp(nodes,[(.26,(.10,.10,.10)),(.38,(.70,.70,.70)),
                          (.56,(1,1,1))],-530,1050)
        links.new(grain.outputs["Fac"],wear.inputs["Fac"])
        pigment = node(nodes,"ShaderNodeMath",-280,800)
        pigment.operation = "MULTIPLY"
        links.new(masks.outputs["Y"],pigment.inputs[0])
        links.new(wear.outputs["Color"],pigment.inputs[1])
        mix = node(nodes,"ShaderNodeMixRGB",-40,520)
        links.new(pigment.outputs[0],mix.inputs[0])
        links.new(dark.outputs[0],mix.inputs[1])
        links.new(red.outputs[0],mix.inputs[2])
        links.new(mix.outputs[0],shader.inputs["Base Color"])
    rough = node(nodes, "ShaderNodeMapRange", -300, 30)
    rough.inputs["From Min"].default_value = 0.15
    rough.inputs["From Max"].default_value = 0.85
    rough.inputs["To Min"].default_value = 0.5 if bronze else 0.70
    rough.inputs["To Max"].default_value = 0.84 if bronze else 0.96
    links.new(medium.outputs["Fac"], rough.inputs["Value"])
    links.new(rough.outputs["Result"], shader.inputs["Roughness"])
    fine_bump = node(nodes, "ShaderNodeBump", -260, -200)
    fine_bump.inputs["Strength"].default_value = 0.25 if bronze else 0.28
    fine_bump.inputs["Distance"].default_value = 0.003 if bronze else 0.008
    links.new(grain.outputs["Fac"], fine_bump.inputs["Height"])
    relief = node(nodes, "ShaderNodeBump", 30, -180)
    relief.inputs["Strength"].default_value = 0.16
    relief.inputs["Distance"].default_value = 0.008 if bronze else 0.020
    links.new(medium.outputs["Fac"], relief.inputs["Height"])
    links.new(fine_bump.outputs["Normal"], relief.inputs["Normal"])
    links.new(relief.outputs["Normal"], shader.inputs["Normal"])
    value["pbr_bake"] = "BaseColor / Roughness / tangent Normal; no external textures"
    return value


PROFILE = [(0.90, 0.97, 0.65), (1.45, 0.99, 0.65), (2.40, 0.90, 0.61),
           (3.40, 0.77, 0.56), (4.10, 0.72, 0.50), (4.80, 0.84, 0.52),
           (5.32, 1.04, 0.57), (5.64, 0.93, 0.51), (6.05, 0.37, 0.32)]


def profile(z):
    for a, b in zip(PROFILE, PROFILE[1:]):
        if z <= b[0]:
            t = max(0, (z - a[0]) / (b[0] - a[0]))
            t = t * t * (3 - 2 * t)
            return a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t
    return PROFILE[-1][1:]


def robe_point(theta, z, cloak=False):
    rx, ry = profile(z)
    skirt = max(0, min(1, (4.7 - z) / 2.6))
    amplitude = 0.025 + 0.095 * skirt
    folds = amplitude * (0.72 * cos(12 * theta + 0.22 * sin(z * 1.3))
                          + 0.28 * cos(7 * theta - z * 0.35))
    if cloak:
        folds = 0.06 * cos(10 * theta + 0.16 * z) + 0.025 * cos(5 * theta)
        shoulder_blend = max(0, min(1, (z - 5.05) / 0.60))
        rx += 0.11 * (1 - shoulder_blend) - 0.10 * shoulder_blend
        ry += 0.14 * (1 - shoulder_blend) - 0.07 * shoulder_blend
        folds *= 1 - 0.75 * shoulder_blend
    x = (rx + folds) * sin(theta)
    y = (ry + folds) * cos(theta)
    return x, y, z


def robes(stone):
    rings = []
    levels = [.90+5.15*row/60 for row in range(61)]
    levels.extend(6.05+.80*row/16 for row in range(1,17))
    neck = [(5.64,.93,.51,0),(5.85,.65,.38,-.04),
            (6.05,.37,.23,-.12),(6.25,.25,.16,-.23),
            (6.50,.13,.10,-.35),(6.85,.07,.06,-.40)]
    for z in levels:
        t = min(1,(z-.90)/5.15)
        ring = []
        for col in range(128):
            angle = TAU * col / 128
            point = robe_point(angle, z)
            if z > 5.64:
                for a,b in zip(neck,neck[1:]):
                    if z <= b[0]:
                        f = max(0,min(1,(z-a[0])/(b[0]-a[0])))
                        f = f*f*(3-2*f)
                        rx,ry,cy = (a[i]+(b[i]-a[i])*f for i in (1,2,3))
                        break
                old_rx,old_ry = profile(z)
                point = (point[0]*rx/old_rx,cy+point[1]*ry/old_ry,z)
            hem = 0.035 * sin(7 * angle) ** 2 * (1 - t) ** 9
            ring.append((point[0], point[1], point[2] + hem))
        rings.append(ring)
    loft("Túnica_Pliegues_Continuos", rings, stone, wear=True)

    # The cloak overlaps the back/shoulders and leaves a continuous front opening.
    rings = []
    for row in range(44):
        t = row / 43
        z = 0.92 + 4.73 * t
        rings.append([robe_point(0.58 + (TAU - 1.16) * col / 100, z, True)
                      for col in range(101)])
    solidify(loft("Manto_Espalda_y_Caída", rings, stone, closed=False,
                  caps=False, wear=True), 0.075)

    # The old short chest/skirt panels are replaced by the continuous stole.


def catmull(points, t):
    scaled = t * (len(points) - 1)
    i = min(int(scaled), len(points) - 2)
    f = scaled - i
    p0 = Vector(points[max(0, i - 1)])
    p1, p2 = Vector(points[i]), Vector(points[i + 1])
    p3 = Vector(points[min(len(points) - 1, i + 2)])
    return 0.5 * ((2 * p1) + (-p0 + p2) * f
                  + (2 * p0 - 5 * p1 + 4 * p2 - p3) * f * f
                  + (-p0 + 3 * p1 - 3 * p2 + p3) * f * f * f)


def sweep(name, points, material, radius_start, radius_end,
          rows=24, sides=24, sleeve=False):
    rings = []
    previous_tangent = None
    u = None
    for row in range(rows + 1):
        t = row / rows
        p = catmull(points, t)
        tangent = (catmull(points, min(1, t + 0.002))
                   - catmull(points, max(0, t - 0.002))).normalized()
        # Parallel transport avoids the old frame flip at a vertical elbow.
        if previous_tangent is None:
            reference = Vector((0, 1, 0))
            u = (reference - tangent * reference.dot(tangent)).normalized()
        else:
            u = previous_tangent.rotation_difference(tangent) @ u
            u = (u - tangent * u.dot(tangent)).normalized()
        v = tangent.cross(u).normalized()
        previous_tangent = tangent
        radius = radius_start * (1 - t) + radius_end * t
        ring = []
        for col in range(sides):
            a = TAU * col / sides
            folded = radius + (0.035 * cos(6 * a + t * 2) if sleeve else 0)
            offset = u * (cos(a) * folded)
            offset += v * (sin(a) * folded)
            if sleeve:
                offset.z -= 0.12 * sin(pi * t) * max(0, -offset.z / max(radius, 0.01))
            ring.append(tuple(p + offset))
        rings.append(ring)
    return loft(name, rings, material, wear=sleeve)


def ovoid(name, center, size, material, segments=24, rows=16):
    rings = []
    for row in range(rows + 1):
        latitude = -pi / 2 + pi * row / rows
        radius = max(0.002, cos(latitude))
        rings.append([(center[0] + size[0] * 0.5 * radius * sin(TAU * col / segments),
                       center[1] + size[1] * 0.5 * radius * cos(TAU * col / segments),
                       center[2] + size[2] * 0.5 * sin(latitude)) for col in range(segments)])
    return loft(name, rings, material)


def union_stone(objects, name, voxel, smooth_iterations=3, ratio=0.5):
    """Fuse actual volumes; retain a named, editable sculpt rather than seams."""
    bpy.ops.object.select_all(action="DESELECT")
    for obj in objects:
        bpy.context.view_layer.objects.active = obj
        for modifier in list(obj.modifiers):
            bpy.ops.object.modifier_apply(modifier=modifier.name)
        obj.select_set(True)
    bpy.context.view_layer.objects.active = objects[0]
    bpy.ops.object.join()
    obj = bpy.context.object
    obj.name = name
    modifier = obj.modifiers.new("Continuidad de los volúmenes tallados", "REMESH")
    modifier.mode = "VOXEL"
    modifier.voxel_size = voxel
    modifier.use_smooth_shade = True
    bpy.ops.object.modifier_apply(modifier=modifier.name)
    modifier = obj.modifiers.new("Pulido de uniones de cantería", "SMOOTH")
    modifier.factor, modifier.iterations = 0.55, smooth_iterations
    bpy.ops.object.modifier_apply(modifier=modifier.name)
    modifier = obj.modifiers.new("Geometría de la escultura", "DECIMATE")
    modifier.ratio = ratio
    bpy.ops.object.modifier_apply(modifier=modifier.name)
    # Joining pieces of one material can leave duplicate slots; normalize them.
    mat = obj.data.materials[0]
    obj.data.materials.clear()
    obj.data.materials.append(mat)
    for poly in obj.data.polygons:
        poly.material_index = 0
        poly.use_smooth = True
    return obj


def sleeve_paths():
    paths = {}
    for side in (-1, 1):
        hand_z = HAND_HEIGHTS[side]
        if side == 1:
            shoulder = Vector((0.83, -0.035, 5.53))
            elbow = Vector((1.23, 0.27, 4.64))
            wrist = Vector((0.36, 1.015, hand_z))
            entry, leave = shoulder.lerp(elbow, 0.83), elbow.lerp(wrist, 0.18)
            points = [tuple(shoulder.lerp(entry, i/4)) for i in range(5)]
            points.extend(tuple((1-t)**2*entry + 2*(1-t)*t*elbow + t*t*leave)
                          for t in [i/8 for i in range(1, 9)])
            points.extend(tuple(leave.lerp(wrist, i/6)) for i in range(1, 7))
        else:
            # A descending upper arm, retaining the established elbow and grip.
            points = [(-.87, -.04, 5.75), (-1.015, .04, 5.27),
                      (-1.23, .22, 4.76), (-1.00, .46, 4.58),
                      (-.67, .77, hand_z-.06), (-.36, 1.015, hand_z)]
        paths[side] = points
    return paths


def sleeve_rings(points):
    rows, sides = 60, 64
    rings = []
    previous_tangent, u = None, None
    for row in range(rows+1):
        t = row/rows
        center = catmull(points, t)
        tangent = (catmull(points, min(1, t+.001))
                   - catmull(points, max(0, t-.001))).normalized()
        if previous_tangent is None:
            reference = Vector((0, 1, 0))
            u = (reference-tangent*reference.dot(tangent)).normalized()
        else:
            u = previous_tangent.rotation_difference(tangent) @ u
            u = (u-tangent*u.dot(tangent)).normalized()
        v = tangent.cross(u).normalized()
        previous_tangent = tangent
        radius = .40*(1-t) + .27*t + .025*sin(pi*t)
        end = max(0, min(1, (t-.62)/.38))
        fall = .42*end*end*(3-2*end)
        ring = []
        for col in range(sides):
            a = TAU*col/sides
            fold = .023*cos(6*a+1.3*t) + .012*cos(9*a-2*t)
            offset = (u*cos(a) + v*sin(a))*(radius+fold)
            lower = max(0, -offset.z/max(radius, .01))
            offset.z -= fall*lower**1.6 + .07*sin(pi*t)*lower
            ring.append(center+offset)
        rings.append(ring)
    return rings


def shoulder_mantle(stone):
    """One garment surface: mantle sockets share edges with both sleeves.

    The old flat sleeve caps are absent. Local Hermite patches continue the
    mantle tangent into the preserved lower sleeves. Only the mantle gets an
    inner skin; cuffs keep their original recessed wall and hanging hem.
    """
    sections = [(5.02, .85, .45), (5.29, 1.10, .56), (5.58, 1.04, .57),
                (5.87, .85, .54), (6.13, .65, .48), (6.34, .49, .39),
                (6.46, .34, .26)]
    windows = {1: (4, 22, 17, 31), -1: (4, 22, 96, 110)}
    rows, cols = 45, 128

    def mantle_point(row, col):
        # Round the socket corners in parameter space. The surrounding grid
        # follows the same warp, so the bridge cannot leave four pinched poles.
        rr, cc = row, col
        for r0, r1, c0, c1 in windows.values():
            rm, cm = (r0+r1)/2, (c0+c1)/2
            rh, ch = (r1-r0)/2, (c1-c0)/2
            u, v = (col-cm)/ch, (row-rm)/rh
            reach = max(abs(u), abs(v))
            if 0 < reach < 1.4:
                fade = max(0, min(1, (1.4-reach)/.4))
                fade = fade*fade*(3-2*fade)
                du = u*sqrt(max(0, 1-.5*(v/reach)**2))
                dv = v*sqrt(max(0, 1-.5*(u/reach)**2))
                cc += ch*(du-u)*fade
                rr += rh*(dv-v)*fade
        z, rx, ry = catmull(sections, rr/44)
        a = .65 + (TAU-1.30)*cc/127
        folds = .025*cos(8*a+.8*z) + .012*cos(5*a-1.3*z)
        x = (rx+folds)*sin(a)
        shoulder = exp(-((abs(x)-.78)/.22)**2-((z-5.78)/.37)**2)
        front = max(0,cos(a))
        if front < .24:
            # Match the quarter-power drape with a finite, zero side tangent.
            # The old cos(a)**.25 cusp left a pinched fold at the side seam.
            t = front/.24
            weight = .24**.25*((-2*t**3+3*t*t)+.25*(t**3-t*t))
        else:
            weight = front**.25
        front_drape = .22*shoulder*weight
        return Vector((x, -.04+(ry+folds)*cos(a)+front_drape, z))

    def mantle_surface(row, col, thickness=.056):
        p = mantle_point(row, col)
        dr = mantle_point(min(44,row+.01),col)-mantle_point(max(0,row-.01),col)
        dc = mantle_point(row,min(127,col+.01))-mantle_point(row,max(0,col-.01))
        return p + dr.cross(dc).normalized()*thickness

    verts = [mantle_surface(r,c) for r in range(rows) for c in range(cols)]
    faces = []
    for r in range(rows-1):
        for c in range(cols-1):
            if any(r0 <= r < r1 and c0 <= c < c1 for r0,r1,c0,c1 in windows.values()):
                continue
            i = r*cols+c
            faces.append((i,i+1,i+1+cols,i+cols))

    def join_rings(a, b):
        for j in range(len(a)):
            k = (j+1)%len(a)
            faces.append((a[j],a[k],b[k],b[j]))

    def add_ring(points):
        indices = list(range(len(verts),len(verts)+len(points)))
        verts.extend(points)
        return indices

    for side, points in sleeve_paths().items():
        r0,r1,c0,c1 = windows[side]
        boundary = ([(r1,c) for c in range(c0,c1)]
                    + [(r,c1) for r in range(r1,r0,-1)]
                    + [(r0,c) for c in range(c1,c0,-1)]
                    + [(r,c0) for r in range(r0,r1)])
        rm,cm = (r0+r1)/2,(c0+c1)/2
        rh,ch = (r1-r0)/2,(c1-c0)/2
        rings = sleeve_rings(points)
        start = min(range(1,25),key=lambda r:abs(catmull(points,r/60).z-5.20))
        center = catmull(points,start/60)
        target = rings[start]
        sy = max(abs(p.y-center.y) for p in target)
        sz = max(abs(p.z-center.z) for p in target)
        directions = [(-side*(c-cm)/ch,(r-rm)/rh) for r,c in boundary]
        # A single cyclic correspondence preserves topology and prevents twist.
        choices = []
        for direction in (-1,1):
            for shift in range(64):
                mapping = [(shift+direction*j)%64 for j in range(64)]
                score = sum(((target[k].y-center.y)/sy-f)**2
                            + ((target[k].z-center.z)/sz-h)**2
                            for k,(f,h) in zip(mapping,directions))
                choices.append((score,mapping))
        mapping = min(choices,key=lambda item:item[0])[1]
        previous = [r*cols+c for r,c in boundary]
        origins = [verts[i] for i in previous]
        destinations = [target[k] for k in mapping]
        tangents = []
        for j,((r,c),p,q) in enumerate(zip(boundary,origins,destinations)):
            outside = mantle_surface(rm+(r-rm)*1.12,cm+(c-cm)*1.12)
            length = (q-p).length
            t0 = (p-outside).normalized()*length*.33
            k = mapping[j]
            t1 = (rings[start+1][k]-rings[start-1][k]).normalized()*length*.38
            tangents.append((t0,t1))
        for step in range(1,17):
            t = step/16
            patch = []
            for p,q,(t0,t1) in zip(origins,destinations,tangents):
                patch.append((2*t**3-3*t*t+1)*p+(t**3-2*t*t+t)*t0
                             +(-2*t**3+3*t*t)*q+(t**3-t*t)*t1)
            current = add_ring(patch)
            join_rings(previous,current)
            previous = current
        for row in range(start+1,61):
            current = add_ring([rings[row][k] for k in mapping])
            join_rings(previous,current)
            previous = current
        cuff_outer = previous
        inner = []
        for row in range(13):
            t = .82+.18*row/12
            center = catmull(points,t)
            inner.append(add_ring([center+(rings[round(t*60)][k]-center)*.77 for k in mapping]))
            if row:
                join_rings(inner[-2],inner[-1])
        faces.append(tuple(reversed(inner[0])))
        join_rings(cuff_outer,inner[-1])

    # Close only the mantle. Its inner skin bridges behind the arm roots;
    # it adds no visible pad and does not double the already formed cuff walls.
    inner_start = len(verts)
    verts.extend(mantle_surface(r,c,-.104) for r in range(rows) for c in range(cols))
    for r in range(rows-1):
        for c in range(cols-1):
            i = inner_start+r*cols+c
            faces.append((i+cols,i+1+cols,i+1,i))
    perimeter = (list(range(cols))
                 + [r*cols+cols-1 for r in range(1,rows)]
                 + [(rows-1)*cols+c for c in range(cols-2,-1,-1)]
                 + [r*cols for r in range(rows-2,0,-1)])
    join_rings(perimeter,[inner_start+i for i in perimeter])
    used = sorted({i for face in faces for i in face})
    remap = {old:new for new,old in enumerate(used)}
    mesh_object("Manto_Mangas_Superficie_Compartida", [verts[i] for i in used],
                [tuple(remap[i] for i in f) for f in faces],stone,wear=True)

def squared(v, power=0.58):
    return (1 if v >= 0 else -1) * abs(v) ** power


def hands(stone):
    # Shape the whole fist from the wrist toward the curled fingers. Varying
    # cross sections define the palm, metacarpal wedge and knuckle envelope.
    # The grip channel is then cut through this volume; it does not prescribe
    # the outer silhouette as it did in the old stack of annular XY sections.
    sections = [(.435, 1.085, .115, .103), (.35, 1.105, .140, .115),
                (.24, 1.125, .153, .135), (.12, 1.13, .178, .167),
                (.015, 1.125, .180, .170), (-.080, 1.12, .153, .153),
                (-.135, 1.12, .082, .118), (-.151, 1.12, .015, .040)]
    for side in (-1, 1):
        hand_z = HAND_HEIGHTS[side]
        pieces_before = set(MODEL.objects)
        rings = []
        for row in range(65):
            x, cy, ry, rz = catmull(sections,row/64)
            ring = []
            finger_zone = exp(-((x-.015)/.20)**4)
            for col in range(80):
                a = TAU*col/80
                front = max(0,cos(a))**3
                vertical = (1 if sin(a)>=0 else -1)*abs(sin(a))**.62
                depth = (1 if cos(a)>=0 else -1)*abs(cos(a))**.42
                zz = .012 + rz*vertical
                # Broad, oblique carved planes temper the rounded loft. A small
                # soft intersection preserves a stone arris instead of a crease.
                bottom_plane = -.131 + .17*max(0,x-.16)
                top_plane = .163 - .22*max(0,x-.10)
                zz = .5*(zz+bottom_plane+sqrt((zz-bottom_plane)**2+.006**2))
                zz = .5*(zz+top_plane-sqrt((zz-top_plane)**2+.006**2))
                # A short little-finger side and sloping metacarpal planes.
                xx = x + .048*max(0,-vertical)**1.6*finger_zone
                yy = 1.12+(cy+ry*depth-1.12)*1.02
                joint_z = zz-.065*xx
                groove = sum(.008*exp(-((joint_z-level)/.010)**2)
                             for level in (-.077,.001,.079))
                knuckle = sum(.009*exp(-((joint_z-level)/.026)**2)
                              for level in (-.115,-.038,.040,.116))
                yy += (knuckle-groove)*front*finger_zone
                ring.append((side*xx*.98,yy,hand_z+zz*1.055))
            rings.append(ring)
        fist = loft(f"Puño_Volumen_Palmar_{side}",rings,stone)
        # Boolean is local to the hand, baked into the source before remeshing.
        # The cylinder matches the fixed hilt axis and leaves one continuous fist.
        if side == -1:
            cut_hand_grip(fist,hand_z)
        wrist = sweep(f"Muñeca_{side}",[(side*.60,.84,hand_z-.055),
                      (side*.47,.99,hand_z-.015),(side*.34,1.10,hand_z+.01),
                      (side*.21,1.13,hand_z+.01)],stone,.120,.113,rows=24,sides=24)
        for vertex in wrist.data.vertices:
            vertex.co.z = hand_z + (vertex.co.z-hand_z)*.90
        thumb_tip = (-side*.035,.925,hand_z+.045) if side==1 else (-side*.06,.99,hand_z+.015)
        sweep(f"Masa_Pulgar_{side}",[(side*.275,1.025,hand_z+.045),
              (side*.165,.955,hand_z+.095),(side*.025,.945,hand_z+.075),
              thumb_tip],stone,.066,.046,rows=20,sides=16)
        hand = union_stone([obj for obj in MODEL.objects if obj not in pieces_before],
                          f"Mano_Puño_Esculpido_{side}",.007,smooth_iterations=2,ratio=.60)
        if side == 1:
            # Fuse palm and thumb before cutting the final channel. Cutting
            # only the palm first left a pinched re-entry beside the grip.
            cut_hand_grip(hand,hand_z)


def cut_hand_grip(hand,hand_z):
    bpy.ops.mesh.primitive_cylinder_add(vertices=80,radius=.108,depth=.80,
                                      location=(0,1.12,hand_z))
    cutter = bpy.context.object
    cutter.name = "Temporal_Canal_Empuñadura"
    material = hand.data.materials[0]
    cutter.data.materials.append(material)
    bpy.context.view_layer.objects.active = hand
    cut = hand.modifiers.new("Canal real de agarre","BOOLEAN")
    cut.operation,cut.solver,cut.object = "DIFFERENCE","EXACT",cutter
    bpy.ops.object.modifier_apply(modifier=cut.name)
    bpy.data.objects.remove(cutter,do_unlink=True)
    hand.data.materials.clear()
    hand.data.materials.append(material)
    for face in hand.data.polygons:
        face.material_index = 0
        face.use_smooth = True

def hood(stone):
    # A pointed forward brow; long side tails enter the chest and shoulder mass.
    sections = [(0.035, 0.05, -0.57, 6.40), (0.46, 0.68, -0.49, 6.40),
                (0.68, 0.92, -0.15, 6.42), (0.72, 0.96, 0.27, 6.43),
                (0.65, 0.85, 0.63, 6.40), (0.54, 0.66, 0.82, 6.29),
                (0.47, 0.52, 0.76, 6.28), (0.43, 0.62, 0.20, 6.40),
                (0.32, 0.48, -0.18, 6.40), (0.035, 0.05, -0.34, 6.40)]
    rings = []
    # Interpolate the hood's depth too; ten straight sections made its profile boxy.
    smooth_sections = []
    for row in range(61):
        t = row / 60 * (len(sections) - 1)
        index, f = min(int(t), len(sections) - 2), t - min(int(t), len(sections) - 2)
        values = []
        for axis in range(4):
            p0 = sections[max(0, index - 1)][axis]
            p1, p2 = sections[index][axis], sections[index + 1][axis]
            p3 = sections[min(len(sections) - 1, index + 2)][axis]
            values.append(0.5 * (2*p1 + (-p0+p2)*f + (2*p0-5*p1+4*p2-p3)*f*f
                                + (-p0+3*p1-3*p2+p3)*f*f*f))
        smooth_sections.append(values)
    for rx, rz, y, zc in smooth_sections:
        ring = []
        for col in range(97):
            a = -2.62 + 5.24 * col / 96
            top = max(0, cos(a))
            tail = max(0, (abs(a) - 1.5) / 1.12)
            x = rx * sin(a) * (0.88 + 0.12 * (1 - cos(a))) + (0.15 * tail if a > 0 else -0.15 * tail)
            z = zc + rz * cos(a) + 0.16 * top ** 7 - 0.59 * tail ** 1.5
            front = y + 0.09 * max(0, -cos(a)) + 0.010 * sin(5 * a)
            ring.append((x, front, z))
        rings.append(ring)
    count = len(rings[0])
    faces = []
    for row in range(len(rings)):
        nxt = (row + 1) % len(rings)
        for col in range(count - 1):
            faces.append((row * count + col, row * count + col + 1,
                          nxt * count + col + 1, nxt * count + col))
    faces.append(tuple(row * count for row in reversed(range(len(rings)))))
    faces.append(tuple(row * count + count - 1 for row in range(len(rings))))
    mesh_object("Capucha_Cavidad_Profunda", [v for ring in rings for v in ring],
                faces, stone, wear=True)
    # A rear drape joins the occiput to the mantle, instead of a floating neck.
    rings = []
    back_profile = [(5.15, 0.80, 0.43), (5.40, 0.98, 0.53), (5.60, 0.96, 0.56), (5.78, 0.78, 0.60),
                    (6.02, 0.57, 0.50), (6.30, 0.49, 0.46), (6.58, 0.53, 0.43),
                    (6.85, 0.55, 0.35), (7.03, 0.48, 0.28)]
    for row in range(43):
        z, rx, ry = catmull(back_profile, row / 42)
        rings.append([(rx * sin(0.80 + (TAU-1.60)*col/80),
                       -0.10 + ry * cos(0.80 + (TAU-1.60)*col/80),
                       z) for col in range(81)])
    solidify(loft("Caída_Capucha_Nuca_Hombros", rings, stone, closed=False,
                  caps=False, wear=True), 0.10)


STOLE_PROFILE = [(0.93,.52,.54),(1.5,.52,.54),(2.5,.51,.52),
                 (3.45,.49,.50),(4.10,.46,.40),(4.80,.47,.29),
                 (5.20,.47,.28),(5.60,.46,.24)]
STOLE_FRONT = []
STOLE_SURFACE = None


def slender_x(x):
    return x*(.78+.22*exp(-(abs(x)/.18)**4))


def stole_profile(z):
    for a,b in zip(STOLE_PROFILE,STOLE_PROFILE[1:]):
        if z <= b[0]:
            t = max(0,min(1,(z-a[0])/(b[0]-a[0])))
            t = t*t*(3-2*t)
            return a[1]+(b[1]-a[1])*t,a[2]+(b[2]-a[2])*t
    return STOLE_PROFILE[-1][1:]


def surface_tree(objects):
    vertices,faces = [],[]
    depsgraph = bpy.context.evaluated_depsgraph_get()
    for obj in objects:
        evaluated = obj.evaluated_get(depsgraph)
        mesh = evaluated.to_mesh()
        start = len(vertices)
        vertices.extend(obj.matrix_world @ v.co for v in mesh.vertices)
        faces.extend(tuple(start+i for i in p.vertices) for p in mesh.polygons)
        evaluated.to_mesh_clear()
    return BVHTree.FromPolygons(vertices,faces)


def front_y(tree,x,z):
    hit,_,_,_ = tree.ray_cast(Vector((x,3,z)),Vector((0,-1,0)),6)
    if hit is None:
        raise RuntimeError(f"La estola no encuentra túnica en {x}, {z}")
    return hit.y


def stole(stone,garments):
    # A broad planar face across each band, with shallow bevels at its edges.
    # Depth follows the garment longitudinally, not its rounded cross-section.
    tree = surface_tree(garments)
    global STOLE_SURFACE
    surface_vertices,surface_faces = [],[]
    STOLE_FRONT.clear()
    rows,cols = 141,25
    for row in range(rows):
        z = .93+(5.60-.93)*row/(rows-1)
        center,width = stole_profile(z)
        support = max(front_y(tree,s*(center+width*(i/16-.5)),z)
                      for s in (-1,1) for i in range(17))
        STOLE_FRONT.append((z,support+.070))
    for side in (-1,1):
        vertices,faces = [],[]
        for row in range(rows):
            z,plane = STOLE_FRONT[row]
            center,width = stole_profile(z)
            top = max(0,min(1,(5.60-z)/.40))
            top = top*top*(3-2*top)
            flat = max(0,min(1,(4.85-z)/.75))
            flat = flat*flat*(3-2*flat)
            for col in range(cols):
                u = col/(cols-1)
                x = side*(center+width*(u-.5))
                bevel = .025*max(0,(abs(2*u-1)-.80)/.20)
                support = front_y(tree,x,z)
                rounded = support+(.065+.025*(1-(2*u-1)**2))*top
                planar = plane-bevel
                y = planar*flat+rounded*(1-flat)
                vertices.append((x,y,z))
        for row in range(rows-1):
            for col in range(cols-1):
                i = row*cols+col
                faces.append((i,i+1,i+1+cols,i+cols))
        start = len(surface_vertices)
        surface_vertices.extend((slender_x(x),y,z) for x,y,z in vertices)
        surface_faces.extend(tuple(start+i for i in face) for face in faces)
        # Close into the robe along depth. A normal-based Solidify around the
        # cowl's steep turn pushes side walls outward and creates little spikes.
        count = len(vertices)
        vertices.extend((x,y-.32,z) for x,y,z in vertices[:])
        front_faces = faces[:]
        faces.extend(tuple(count+i for i in reversed(face)) for face in front_faces)
        boundary = (list(range(cols))
                    + [r*cols+cols-1 for r in range(1,rows)]
                    + [(rows-1)*cols+c for c in range(cols-2,-1,-1)]
                    + [r*cols for r in range(rows-2,0,-1)])
        for i,a in enumerate(boundary):
            b = boundary[(i+1)%len(boundary)]
            faces.append((a,b,b+count,a+count))
        mesh_object(f"Estola_Continua_{side}",vertices,faces,stone)
    STOLE_SURFACE = BVHTree.FromPolygons(surface_vertices,surface_faces)


def paint_stole(body):
    # Colour follows the actual carved hood lip and the continuous stole.
    # Face-corner masks preserve sharp red incision boundaries after baking.
    lip = []
    for i in range(193):
        a = -2.62+5.24*i/192
        tail = max(0,(abs(a)-1.5)/1.12)
        x = .54*sin(a)*(.88+.12*(1-cos(a)))+(.15*tail if a>0 else -.15*tail)
        z = 6.29+.66*cos(a)+.16*max(0,cos(a))**7-.59*tail**1.5
        y = .82+.09*max(0,-cos(a))+.010*sin(5*a)
        lip.append(Vector((slender_x(x),y,z)))
    masks = body.data.color_attributes.new(name="Vigia_Pigment",type="FLOAT_COLOR",domain="CORNER")
    vertex_masks = []
    for v in body.data.vertices:
        x,y,z = v.co
        dark = 0.0
        if .915 <= z <= 5.62:
            _,_,_,distance = STOLE_SURFACE.find_nearest(v.co)
            dark = min(1,max(0,(.052-distance)/.022))
        if z >= 5.25 and y > .50:
            distance = sqrt(min((x-p.x)**2+(z-p.z)**2 for p in lip))
            front = min(1,max(0,(y-.53)/.11))
            dark = max(dark,front*min(1,max(0,(.185-distance)/.035)))
        if 5.80 < z < 7.10 and y < .50 and abs(x)<.50 and v.normal.y>.25:
            # Keep the recessed face in the same dark stone family as the lip.
            # This follows the rebuilt cavity; its geometry also stays smooth
            # under the neutral frontal inspection light.
            fade = min(1,(z-5.80)/.30)*min(1,(7.10-z)/.20)
            fade *= min(1,(.50-y)/.30)*min(1,(.50-abs(x))/.08)
            dark = max(dark,fade)
        vertex_masks.append(dark)
    red_faces = 0
    for face in body.data.polygons:
        red = float(face.material_index==1)
        red_faces += int(red)
        for loop_index in face.loop_indices:
            masks.data[loop_index].color = (vertex_masks[body.data.loops[loop_index].vertex_index],red,0,1)
        face.material_index = 0
    if not red_faces:
        raise RuntimeError("El grabado no conserva caras para el pigmento rojo")
    body.data.materials.pop(index=1)
    body['pigment'] = 'Worn matte red in incisions; hood lip and flat stole darkened to 32% stone albedo; no emission'
    print(f"PIGMENTO_OK {red_faces} caras talladas",flush=True)


# English text requested by the user; rendered with Sith AF (Kittat, Legends).
# This is a visual transliteration, not a Sith-language translation.
SITH_CODE = (
    "Peace is a lie, there is only passion.",
    "Through passion, I gain strength.",
    "Through strength, I gain power.",
    "Through power, I gain victory.",
    "Through victory, my chains are broken.",
    "The Force shall free me.",
)
SITH_FONT = ROOT / "tools/blender/fonts/SithAF.otf"


def engrave_stole(body):
    font = bpy.data.fonts.load(str(SITH_FONT))
    font.pack()
    tree = surface_tree([body])

    def text_mesh(text):
        curve = bpy.data.curves.new("Temporal_Texto_Kittat","FONT")
        curve.body,curve.font,curve.size = text,font,1
        curve.extrude,curve.offset,curve.resolution_u = .01,0,3
        curve.space_character = 1.12
        curve.fill_mode = "BOTH"
        obj = bpy.data.objects.new("Temporal_Texto_Kittat",curve)
        MODEL.objects.link(obj)
        bpy.context.view_layer.update()
        mesh = bpy.data.meshes.new_from_object(obj.evaluated_get(bpy.context.evaluated_depsgraph_get()))
        bpy.data.objects.remove(obj,do_unlink=True)
        bpy.data.curves.remove(curve)
        return mesh

    probe = text_mesh("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    ref_top = max(v.co.y for v in probe.vertices)
    ref_bottom = min(v.co.y for v in probe.vertices)
    scale = .105/(ref_top-ref_bottom)
    bpy.data.meshes.remove(probe)
    vertices,faces,layout = [],[],[]
    # Front view: +X is the viewer's left. Read its verses 1-3 first, then
    # verses 4-6 on the right. Within each band: rows down, letters left to right.
    for side,verses in ((1,SITH_CODE[:3]),(-1,SITH_CODE[3:])):
        rows = []
        for verse in verses:
            text = ''.join(c for c in verse.upper() if c.isalpha() or c==' ')
            rows.extend(text[i:i+6] for i in range(0,len(text),6))
        pitch = (3.78-1.10)/(len(rows)-1)
        band = {"front_band":"left" if side==1 else "right","verses":list(verses),"rows":[]}
        for index,text in enumerate(rows):
            mesh = text_mesh(text)
            if not mesh.vertices:
                raise RuntimeError(f"Texto sin glifos: {text!r}")
            xmin = min(v.co.x for v in mesh.vertices);xmax = max(v.co.x for v in mesh.vertices)
            zmin = min(v.co.z for v in mesh.vertices);zmax = max(v.co.z for v in mesh.vertices)
            top = 3.78-index*pitch
            center,width = stole_profile(top-.0525)
            center = side*slender_x(center)
            max_width = width*.78*.84
            sx = min(scale,max_width/max(.001,xmax-xmin))
            start = len(vertices)
            for v in mesh.vertices:
                x = center-(v.co.x-(xmin+xmax)/2)*sx
                z = top+(v.co.y-ref_top)*scale
                depth = -.002+.022*(v.co.z-zmin)/max(.0001,zmax-zmin)
                vertices.append((x,front_y(tree,x,z)+depth,z))
            faces.extend(tuple(start+i for i in p.vertices) for p in mesh.polygons)
            band['rows'].append({'text':text,'top_z':top})
            bpy.data.meshes.remove(mesh)
        layout.append(band)
    incision_material = bpy.data.materials.new("Temporal_Mascara_Incisiones")
    body.data.materials.append(incision_material)
    cutter = mesh_object("Temporal_Codigo_Sith",vertices,faces,incision_material,smooth=False)
    # Blender text caps and side walls arrive with coincident but unwelded
    # vertices. A boolean needs closed solids, otherwise only fragments cut.
    bm = bmesh.new()
    bm.from_mesh(cutter.data)
    bmesh.ops.remove_doubles(bm,verts=list(bm.verts),dist=.000001)
    bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
    if any(not e.is_manifold for e in bm.edges):
        raise RuntimeError("El cortador de la inscripción no está cerrado")
    bm.to_mesh(cutter.data)
    bm.free()
    bpy.context.view_layer.objects.active = body
    body.select_set(True)
    modifier = body.modifiers.new("Código Sith inciso en estola","BOOLEAN")
    modifier.operation,modifier.solver,modifier.object = "DIFFERENCE","EXACT",cutter
    modifier.use_self = True
    bpy.ops.object.modifier_apply(modifier=modifier.name)
    bpy.data.objects.remove(cutter,do_unlink=True)
    paint_stole(body)
    bpy.data.materials.remove(incision_material)
    body['inscription'] = '\n'.join(SITH_CODE)
    body['lettering_attribution'] = 'Sith AF by Ender Smith / AurekFonts; CC BY 3.0 US'
    body['inscription_reading'] = 'Front left band verses 1-3, front right 4-6; top-to-bottom rows, left-to-right letters'
    import json,hashlib
    REFERENCE_DIR.mkdir(parents=True,exist_ok=True)
    (REFERENCE_DIR/'inscription_layout.json').write_text(json.dumps({
        'language':'English','representation':'Sith AF / Legends Kittat; visual transliteration',
        'font_sha256':hashlib.sha256(SITH_FONT.read_bytes()).hexdigest(),
        'font_license':'CC BY 3.0 US; Ender Smith / AurekFonts',
        'font_source':'https://www.dafont.com/sith-af.font',
        'reading_order':body['inscription_reading'],'glyph_height_m':.105,
        'punctuation':'Latin commas and full stops omitted; all letters and word spaces retained',
        'incision_depth_m':.002,'pigment':'Worn matte red, non-emissive',
        'stole':'Wider front-facing flat bands, 32% stone albedo, continuous dark hood lip','bands':layout,
    },indent=2,ensure_ascii=False)+'\n',encoding='utf-8')

def prism(name, outline, y, thickness, mat, bevel=0.015):
    verts = [(x, y + depth, z) for depth in (0, -thickness) for x, z in outline]
    n = len(outline)
    faces = [tuple(range(n)), tuple(reversed(range(n, 2 * n)))]
    faces.extend((i, (i + 1) % n, (i + 1) % n + n, i + n) for i in range(n))
    obj = mesh_object(name, verts, faces, mat, smooth=False)
    if bevel:
        modifier = obj.modifiers.new("Filo tallado", "BEVEL")
        modifier.width = bevel
        modifier.segments = 2
    return obj


def vibroblade(stone, pale, bronze):
    before_weapon = set(MODEL.objects)
    # Narrow curved edge, extended mechanical heel and a wrapped long grip.
    # Original geometry interpreted from the user's weapon references; no glow.
    prism("Vibrohoja_Filo_Curvo", [(-0.10, 4.48), (-0.12, 3.68), (-0.105, 2.50),
          (-0.04, 1.64), (0.09, 1.24), (0.30, 0.99), (0.20, 1.52),
          (0.18, 2.44), (0.19, 3.66), (0.16, 4.48)], 1.19, 0.105, pale, 0.009)
    prism("Vibrohoja_Plano_Lomo", [(-0.10, 4.45), (-0.11, 3.62), (-0.09, 2.47),
          (-0.02, 1.65), (0.09, 1.29), (0.16, 1.19), (0.08, 1.73),
          (0.04, 2.46), (0.045, 3.62), (0.04, 4.45)], 1.212, 0.025, stone, 0.005)
    prism("Carcasa_Resonador_Alargada", [(-0.145, 4.48), (-0.20, 4.37),
          (-0.20, 3.91), (-0.135, 3.57), (-0.02, 3.72), (0.12, 4.28),
          (0.12, 4.48)], 1.26, 0.22, pale, 0.018)
    prism("Guarda_Asimétrica_Ceremonial", [(-0.46, 4.54), (-0.42, 4.41),
          (-0.13, 4.43), (0.13, 4.43), (0.36, 4.49), (0.39, 4.62),
          (0.29, 4.59), (0.09, 4.53), (-0.10, 4.54)], 1.255, 0.235, bronze, 0.013)
    prism("Filete_Mecanismo", [(-0.16, 4.36), (-0.16, 3.98), (-0.11, 3.77),
          (-0.075, 3.84), (-0.11, 4.02), (-0.11, 4.37)], 1.281, 0.025, bronze, 0.005)
    for index in range(5):
        z = 3.99 + index * 0.077
        prism(f"Puerto_Resonador_{index}", [(-0.085, z), (0.015, z + 0.018),
              (0.015, z + 0.046), (-0.085, z + 0.028)], 1.284, 0.025, bronze, 0.004)
    rings = []
    for row in range(75):
        z = 4.53 + row * 0.012
        radius = 0.096 + 0.008 * cos(row * 0.012 / 0.075 * TAU)
        rings.append([(radius * sin(TAU * col / 24),
                       1.12 + radius * cos(TAU * col / 24), z) for col in range(24)])
    loft("Empuñadura_Ceñida", rings, stone)
    for z in (4.57, 5.43):
        rings = [[(0.109 * sin(TAU * col / 24), 1.12 + 0.109 * cos(TAU * col / 24), zz)
                  for col in range(24)] for zz in (z - 0.025, z + 0.025)]
        loft(f"Virola_Empuñadura_{z}", rings, bronze)
    prism("Pomo_Facetado", [(-0.10, 5.45), (-0.13, 5.52), (-0.07, 5.61),
          (0.07, 5.61), (0.13, 5.52), (0.10, 5.45)], 1.235, 0.23, bronze, 0.014)
    # Shorten the blade with the point still at the pedestal; lower the hilt.
    for obj in MODEL.objects:
        if obj in before_weapon:
            continue
        for vertex in obj.data.vertices:
            if obj.name in ("Vibrohoja_Filo_Curvo", "Vibrohoja_Plano_Lomo"):
                vertex.co.z = .99 + (vertex.co.z-.99)*(4.48-SWORD_DROP-.99)/(4.48-.99)
            else:
                vertex.co.z -= SWORD_DROP


def pedestal(stone, pale):
    # Rounded eight-sided platform stays inside the previous collision footprint.
    rings = []
    sections = [(0.00, 1.78, 1.48), (0.07, 1.85, 1.55), (0.16, 1.85, 1.55),
                (0.21, 1.80, 1.50), (0.62, 1.74, 1.45), (0.68, 1.80, 1.50),
                (0.76, 1.80, 1.50), (0.82, 1.67, 1.38), (0.90, 1.61, 1.32)]
    for z, rx, ry in sections:
        ring = []
        for col in range(64):
            a = TAU * col / 64
            def shaped(v):
                return (1 if v >= 0 else -1) * abs(v) ** 0.35
            ring.append((rx * shaped(sin(a)), ry * shaped(cos(a)), z))
        rings.append(ring)
    loft("Pedestal_Piedra_Tallada", rings, stone, smooth=True, wear=True)
    # A shallow stone band has close value; it avoids the previous white stripe.
    rings = []
    for z in (0.66, 0.70):
        rings.append([(1.785 * (1 if sin(TAU * i / 64) >= 0 else -1)
                       * abs(sin(TAU * i / 64)) ** 0.35,
                       1.485 * (1 if cos(TAU * i / 64) >= 0 else -1)
                       * abs(cos(TAU * i / 64)) ** 0.35, z) for i in range(64)])
    loft("Filete_de_Piedra", rings, pale, smooth=True)


def aim_at(obj, target):
    obj.rotation_euler = (Vector(target) - obj.location).to_track_quat("-Z", "Y").to_euler()


def studio():
    scene = bpy.context.scene
    scene.unit_settings.system = "METRIC"
    scene.world = bpy.data.worlds.new("Vigia_Studio_World")
    scene.world.use_nodes = True
    background = scene.world.node_tree.nodes.get("Background")
    background.inputs["Color"].default_value = (0.12, 0.135, 0.15, 1)
    background.inputs["Strength"].default_value = 0.30
    scene.view_settings.view_transform = "AgX"
    scene.view_settings.look = "AgX - Medium High Contrast"
    scene.render.image_settings.file_format = "PNG"
    scene.render.image_settings.color_mode = "RGB"
    scene.render.film_transparent = False
    for name, pos, energy, size in [
            ("Key", (-5, 7, 11), 1700, 7), ("Fill", (6, 3, 10), 500, 8),
            ("Rim", (2, -5, 9), 1400, 6)]:
        light = bpy.data.lights.new(name, "AREA")
        light.energy, light.shape, light.size = energy, "DISK", size
        obj = bpy.data.objects.new(name, light)
        STUDIO.objects.link(obj)
        obj.location = pos
        aim_at(obj, (0, 0, 4))
    camera_data = bpy.data.cameras.new("Vigia_Reference_Camera")
    camera_data.type, camera_data.ortho_scale = "ORTHO", 8.85
    camera = bpy.data.objects.new("Vigia_Reference_Camera", camera_data)
    STUDIO.objects.link(camera)
    camera.location = (0, 18, 5.0)
    aim_at(camera, (0, 0, 3.8))
    scene.camera = camera
    ground_mesh = bpy.data.meshes.new("Studio_Ground")
    ground_mesh.from_pydata([(-200, -200, -0.035), (200, -200, -0.035),
                            (200, 200, -0.035), (-200, 200, -0.035)], [], [(0, 1, 2, 3)])
    ground = bpy.data.objects.new("Studio_Ground", ground_mesh)
    STUDIO.objects.link(ground)
    ground_mat = bpy.data.materials.new("Preview_Ground_Only")
    ground_mat.use_nodes = True
    ground_mat.node_tree.nodes.get("Principled BSDF").inputs["Base Color"].default_value = (0.065, 0.075, 0.085, 1)
    ground_mat.node_tree.nodes.get("Principled BSDF").inputs["Roughness"].default_value = 0.92
    ground_mesh.materials.append(ground_mat)
    scene["asset_name"] = "Vigía del Umbral — iteración 08"
    scene["asset_orientation"] = "Source front +Y; export turns toward Godot +Z"
    scene["source_script"] = "tools/blender/create_vigia.py"
    scene["human_acceptance"] = "Pending visual review of iteration 08"
    scene["rune_note"] = "English Sith Code rendered with Sith AF / Legends Kittat; not a Sith-language translation"


def render_views(draft=False):
    scene = bpy.context.scene
    scene.render.engine = "BLENDER_EEVEE" if draft else "CYCLES"
    if not draft:
        scene.cycles.samples = 32
        scene.cycles.use_denoising = True
        scene.cycles.max_bounces = 5
    scene.render.resolution_x = 720 if draft else 960
    scene.render.resolution_y = 900 if draft else 1200
    scene.render.resolution_percentage = 100
    black = bpy.data.materials.new("Preview_Silhouette_Only")
    black.use_nodes = True
    black.node_tree.nodes.clear()
    out = black.node_tree.nodes.new("ShaderNodeOutputMaterial")
    emit = black.node_tree.nodes.new("ShaderNodeEmission")
    emit.inputs["Color"].default_value = (0, 0, 0, 1)
    black.node_tree.links.new(emit.outputs[0], out.inputs["Surface"])
    world = scene.world.node_tree.nodes.get("Background")
    views = [("front_materials.png", (0, 18, 4.9)),
             ("profile_right.png", (18, 0, 4.9)),
             ("three_quarter.png", (12, 18, 6.4)),
             ("back.png", (0, -18, 4.9)),
             ("silhouette.png", (0, 18, 4.9))]
    for filename, position in views:
        silhouette = filename == "silhouette.png"
        scene.camera.location = position
        aim_at(scene.camera, (0, 0, 3.8))
        scene.render.filepath = str(REFERENCE_DIR / filename)
        scene.view_layers[0].material_override = black if silhouette else None
        bpy.data.objects["Studio_Ground"].hide_render = silhouette
        world.inputs["Color"].default_value = (1, 1, 1, 1) if silhouette else (0.12, 0.135, 0.15, 1)
        world.inputs["Strength"].default_value = 1 if silhouette else 0.30
        bpy.ops.render.render(write_still=True)
        print(f"VISTA_OK {filename}", flush=True)
    scene.view_layers[0].material_override = None
    bpy.data.objects["Studio_Ground"].hide_render = False
    world.inputs["Color"].default_value = (0.12, 0.135, 0.15, 1)
    world.inputs["Strength"].default_value = 0.30
    bpy.data.materials.remove(black)
    for filename, position, target, scale in [
            ("detail_cowl.png", (7, 16, 7.8), (0, 0.15, 6.1), 3.5),
            ("detail_shoulders.png", (0, 18, 6.2), (0, .10, 5.48), 3.25),
            ("detail_stole.png", (5, 17, 4.2), (0, .55, 2.70), 3.7),
            ("detail_inscription.png", (0, 18, 4.0), (0, .60, 3.1), 1.65),
            ("detail_hands.png", (5, 17, 6.5), (0, 0.85, 4.83), 1.95)]:
        scene.camera.data.ortho_scale = scale
        scene.camera.location = position
        aim_at(scene.camera, target)
        scene.render.filepath = str(REFERENCE_DIR / filename)
        bpy.ops.render.render(write_still=True)
        print(f"VISTA_OK {filename}", flush=True)
    scene.camera.data.ortho_scale = 8.85
    scene.camera.location = (12, 18, 6.4)
    aim_at(scene.camera, (0, 0, 3.8))


def main():
    args = argparse.ArgumentParser()
    args.add_argument("--draft", action="store_true")
    args.add_argument("--no-renders", action="store_true")
    opts = args.parse_args(sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else [])
    ensure_version()
    bpy.ops.wm.read_factory_settings(use_empty=True)
    global MODEL, STUDIO, ANCHOR
    MODEL, STUDIO = collection(MODEL_COLLECTION_NAME), collection("VIGIA_PREVIEW")
    ANCHOR = bpy.data.objects.new(MODEL_ROOT_NAME, None)
    MODEL.objects.link(ANCHOR)
    texture = bpy.data.textures.new("Stone_Wear", "CLOUDS")
    texture.noise_scale, texture.noise_depth = 0.18, 1
    stone = material("Basalto_Gris_Desgastado")
    pale = material("Piedra_Clara_Mate", light=True)
    bronze = material("Bronce_Envejecido", bronze=True)
    pedestal(stone, pale)
    body_before = set(MODEL.objects)
    robes(stone)
    hood(stone)
    stole_support = [obj for obj in MODEL.objects if obj not in body_before]
    shoulder_mantle(stone)
    stole(stone,stole_support)
    body = union_stone([obj for obj in MODEL.objects if obj not in body_before],
                "Escultura_Túnica_Capucha_Mangas", 0.025, smooth_iterations=4, ratio=0.25)
    hands(stone)
    # Slender figure, same height/pedestal. Preserve the grip near the centreline.
    for obj in MODEL.objects:
        if obj in body_before:
            continue
        for vertex in obj.data.vertices:
            x = vertex.co.x
            vertex.co.x *= .78 + .22*exp(-(abs(x)/.18)**4)
        obj.data.update()
    engrave_stole(body)
    vibroblade(stone, pale, bronze)
    studio()
    SOURCE.parent.mkdir(parents=True, exist_ok=True)
    REFERENCE_DIR.mkdir(parents=True, exist_ok=True)
    bpy.context.preferences.filepaths.save_version = 0
    bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE))
    if not opts.no_renders:
        render_views(opts.draft)
    bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE))
    print(f"FUENTE_OK {SOURCE}", flush=True)
    print(f"Objetos editables: {len([o for o in MODEL.objects if o.type == 'MESH'])}", flush=True)


if __name__ == "__main__":
    main()
