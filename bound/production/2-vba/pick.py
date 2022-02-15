#!/usr/bin/env python
# Initial code come from CHARMM-GUI 
# Modified the output and some atom selection rules by AC.


import math, sys

class coord:
    def __init__(self, x, y, z):
        self.x = x
        self.y = y
        self.z = z

class lig_atom:
    def __init__(self, name, num, x, y, z, res_name, res_num, segid):
        self.name = name
        self.num = num
        self.x = x
        self.y = y
        self.z = z
        self.res_name = res_name
        self.res_num = res_num
        self.segid = segid

def calc_angle(site1, site2, site3):
    vec1 = coord(site1.x - site2.x, site1.y - site2.y, site1.z - site2.z)
    norm1 = math.sqrt(vec1.x*vec1.x + vec1.y*vec1.y + vec1.z*vec1.z)
    vec2 = coord(site3.x - site2.x, site3.y - site2.y, site3.z - site2.z)
    norm2 = math.sqrt(vec2.x*vec2.x + vec2.y*vec2.y + vec2.z*vec2.z)
    cos_theta  = vec1.x*vec2.x + vec1.y*vec2.y + vec1.z*vec2.z
    cos_theta /= norm1
    cos_theta /= norm2
    theta = math.degrees(math.acos(cos_theta))
    return theta


def calc_dihedral(site1, site2, site3, site4):
    dij = [site1.x-site2.x, site1.y-site2.y, site1.z-site2.z] 
    djk = [site2.x-site3.x, site2.y-site2.y, site2.z-site3.z] 
    dlk = [site4.x-site3.x, site4.y-site2.y, site4.z-site3.z] 
    aijk = [dij[1]*djk[2]-dij[2]*djk[1], dij[2]*djk[0]-dij[0]*djk[2], dij[0]*djk[1]-dij[1]*djk[0]]
    ajkl = [dlk[1]*djk[2]-dlk[2]*djk[1], dlk[2]*djk[0]-dlk[0]*djk[2], dlk[0]*djk[1]-dlk[1]*djk[0]]
    raijk2 = aijk[0]*aijk[0] + aijk[1]*aijk[1] + aijk[2]*aijk[2]
    rajkl2 = ajkl[0]*ajkl[0] + ajkl[1]*ajkl[1] + ajkl[2]*ajkl[2]
    inv_raijk2  = 1.0 / raijk2
    inv_rajkl2  = 1.0 / rajkl2
    inv_raijkl = math.sqrt(inv_raijk2*inv_rajkl2)
    cos_phi = (aijk[0]*ajkl[0] + aijk[1]*ajkl[1] + aijk[2]*ajkl[2])*inv_raijkl
    rjk     = math.sqrt(djk[0]*djk[0] + djk[1]*djk[1] + djk[2]*djk[2])
    inv_rjk = 1.0 / rjk
    sin_phi = rjk * inv_raijkl * (aijk[0]*dlk[0] + aijk[1]*dlk[1] + aijk[2]*dlk[2])
    phi = math.degrees(math.asin(sin_phi))
    return phi


if __name__ == "__main__":

    # Set segment IDs for ligand and protein
    #lig_segid = "LIG"
    lig_resname = "BEN"
    #pro_segid = "PROT"

    ## Get ligand's heavy atoms and protein's residues.
    lig_atoms = []
    pro_residues = []
    pro_atoms = []
    res_name_pre = ""
    res_num_pre = -999999
    idx_res = -1
    for line in open("ref-complex.pdb"):
        if line.startswith("ATOM"):
            segid = line[72:76].strip()
            atom_name = line[12:16].strip()
            atom_num  = int(line[5:11].strip())
            res_name = line[17:21].strip()
            res_num  = int(line[22:26].strip())
            x  = float(line[30:38].strip())
            y  = float(line[38:46].strip())
            z  = float(line[46:54].strip())
            if res_name == lig_resname:
                if not atom_name.startswith("H"):
                    lig_atoms.append(lig_atom(atom_name, atom_num, x, y, z, res_name, res_num, segid))
            else:
                if atom_name in ["N", "C", "O", "CA"]:
                    pro_atoms.append(lig_atom(atom_name, atom_num, x, y, z, res_name, res_num, segid))

    ## Calculate ligand's center.
    num_lig_atoms = len(lig_atoms)
    lig_center = coord(0.0, 0.0, 0.0)
    for i in range(num_lig_atoms):
        lig_center.x += lig_atoms[i].x
        lig_center.y += lig_atoms[i].y
        lig_center.z += lig_atoms[i].z
    lig_center.x /= float(num_lig_atoms)
    lig_center.y /= float(num_lig_atoms)
    lig_center.z /= float(num_lig_atoms)

    ## Get ligand atom 1 (latm1), which is the closest to the center of the ligand.
    dist_min = 10000.0
    for i in range(num_lig_atoms):
        dist  = (lig_atoms[i].x - lig_center.x) * (lig_atoms[i].x - lig_center.x)
        dist += (lig_atoms[i].y - lig_center.y) * (lig_atoms[i].y - lig_center.y)
        dist += (lig_atoms[i].z - lig_center.z) * (lig_atoms[i].z - lig_center.z)
        dist = math.sqrt(dist)
        if dist < dist_min:
            idx_latm1 = i
            dist_min = dist
    latm1 = lig_atoms[idx_latm1]

    ## Get protein residue 1 (pres1), which is the closes to latm1.
    #num_pro_residues = len(pro_residues)
    num_pro_atoms = len(pro_atoms)
    pro_site_residues = []
    dist_min = 10000.0
    for i in range(num_pro_atoms):
        #res = pro_residues[i]
        dist  = (pro_atoms[i].x - latm1.x) * (pro_atoms[i].x - latm1.x)
        dist += (pro_atoms[i].y - latm1.y) * (pro_atoms[i].y - latm1.y)
        dist += (pro_atoms[i].z - latm1.z) * (pro_atoms[i].z - latm1.z)
        dist = math.sqrt(dist)
        if dist <= 10.0 and dist > 1.0:
            #pro_site_residues.append(pro_residues[i])
            if dist < dist_min:
                idx_pres1 = i
                dist_min = dist
    dist1 = dist_min
    patm1 = pro_atoms[idx_pres1]
    

    ## Get protein residue 2 (pres2).
    ## The pres2-pres1-latm1 angle is the closest to 90 degree.
    #num_pro_site_residues = len(pro_site_residues)
    theta_min = 1000.0
    for i in range(num_pro_atoms):
        #res = pro_site_residues[i]
        if pro_atoms[i].res_num != patm1.res_num:
            theta = calc_angle(latm1, patm1, pro_atoms[i])
            dist  = (pro_atoms[i].x - patm1.x) * (pro_atoms[i].x - patm1.x)
            dist += (pro_atoms[i].y - patm1.y) * (pro_atoms[i].y - patm1.y)
            dist += (pro_atoms[i].z - patm1.z) * (pro_atoms[i].z - patm1.z)
            dist  = math.sqrt(dist)
            if dist > 1.0 and dist <= 10.0:
                if abs(theta-90.0) < abs(theta_min-90.0):
                    idx_pres2 = i
                    theta_min = theta
    angle1 = theta_min
    patm2 = pro_atoms[idx_pres2]

    ## Get protein residue 3 (pres3).
    ## The pres3-pres2-pres1 angle falls within the range 60 to 120 degree.
    ## The pres3-pres2 distance is the closest to the pres1-latm1 distance.
    dist0  = (patm1.x - latm1.x) * (patm1.x - latm1.x)
    dist0 += (patm1.y - latm1.y) * (patm1.y - latm1.y)
    dist0 += (patm1.z - latm1.z) * (patm1.z - latm1.z)
    dist0  = math.sqrt(dist0)
    dist_min = 10000.0
    for i in range(num_pro_atoms):
        #res = pro_site_residues[i]
        if pro_atoms[i].res_num != patm1.res_num and pro_atoms[i].res_num != patm2.res_num:
            theta = calc_angle(patm1, patm2, pro_atoms[i])
            dist  = (pro_atoms[i].x - patm2.x) * (pro_atoms[i].x - patm2.x)
            dist += (pro_atoms[i].y - patm2.y) * (pro_atoms[i].y - patm2.y)
            dist += (pro_atoms[i].z - patm2.z) * (pro_atoms[i].z - patm2.z)
            dist  = math.sqrt(dist)
#             phi = calc_dihedral(latm1, pres1, pres2, res)
#             if phi >= -120.0 and phi <= 120.0:
            if abs(dist-dist0) < abs(dist_min-dist0):
                idx_pres3 = i
                dist_min = dist
                theta_min = theta
    patm3 = pro_atoms[idx_pres3]

    ## Get ligand atom 2 (latm2).
    ## The pres1-latm1-latm2 angle is the closest to 90 degree.
    theta_min = 1000.0
    for i in range(num_lig_atoms):
        atm = lig_atoms[i]
        if atm != latm1:
            theta = calc_angle(patm1, latm1, atm)
            dist  = (atm.x - latm1.x) * (atm.x - latm1.x)
            dist += (atm.y - latm1.y) * (atm.y - latm1.y)
            dist += (atm.z - latm1.z) * (atm.z - latm1.z)
            dist  = math.sqrt(dist)
            if dist > 1.0:
                if abs(theta-90.0) < abs(theta_min-90.0):
                    idx_latm2 = i
                    theta_min = theta
    latm2 = lig_atoms[idx_latm2]

    ## Get ligand atom 3 (latm3).
    ## The latm3-latm2-latm1 angle falls within the range 60 to 120 degree.
    ## The latm3-latm2 distance is the closest to the pres1-latm1 distance.
    ## [AC] angle closest to 90 degree.
    ## [AC] maybe should add non adjacent atom (e.g. > 1.8A distance)
    dist_min = 10000.0
    theta_min = 1000.0
    for i in range(num_lig_atoms):
        atm = lig_atoms[i]
        if atm != latm1 and atm != latm2:
            theta = calc_angle(latm1, latm2, atm)
            dist  = (atm.x - latm2.x) * (atm.x - latm2.x)
            dist += (atm.y - latm2.y) * (atm.y - latm2.y)
            dist += (atm.z - latm2.z) * (atm.z - latm2.z)
            dist  = math.sqrt(dist)
#             phi = calc_dihedral(pres1, latm1, latm2, atm)
#             if phi >= -120.0 and phi <= 120.0:
            if abs(theta-90.0) < abs(theta_min-90.0):
                if abs(dist-dist0) < abs(dist_min-dist0):
                    idx_latm3 = i
                    dist_min = dist
                    theta_min = theta
    latm3 = lig_atoms[idx_latm3]

    angle1 = calc_angle(latm1, patm1, patm2)
    angle2 = calc_angle(latm2, latm1, patm1)
    dihed1 = calc_dihedral(patm2, patm1, latm1, latm2)
    dihed2 = calc_dihedral(patm3, patm2, patm1, latm1)
    dihed3 = calc_dihedral(patm1, latm1, latm2, latm3)

    f = open("vba-auto.dat", "w")
    f.write("%s,%s,%s,%s,%s,%s\n" % (latm1.num,latm2.num,latm3.num,patm1.num,patm2.num,patm3.num))
    f.write("%s,%s,%s,%s,%s,%s\n" % (dist1,angle1,angle2,dihed1,dihed2,dihed3))
    f.close()
