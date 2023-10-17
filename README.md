# PC_PML_code

This project contains code pertaining to the study "Multiparametric profiling of pre-metastatic liver biopsies predicts metastatic outcome in patients with early-stage pancreatic cancer" by L. Bojmar, C.P. Zambirinis, et al, submitted for review to Nature Medicine (NMED-A128912).

CONTENTS
  A. Scripts for quantification of immunostains on human liver sections using ImageJ FIJI.
    (1) A1_IHC_Ki67Counts.ijm --> Quantification of Ki67 positive cells stained by IHC.
    (2) A2_IF_CD3CD8_avoid_RBC.ijm --> Quantification of IF-stained CD3+ cells (T cells), CD3+ CD8+ cells (CD8+ T cells), and CD3+ CD8- cells (mainly CD4+ T cells, but also other lymphocytes).
    (3) A3_IHC_IBA1_area_LB.ijm --> Quantification of stained area as percent of total tissue area (e.g. IBA-1, CD45, NETs).
    (4) A4_IF_CD11b__03-05.ijm -->  Quantification of IF-stained CD11B+ cells (AF488).
    (5) A5_IF_CD11bCD68CD206_02-12.ijm -->  Quantification of IF-stained CD68+ cells (AF594) and CD206+ cells (AF647). Slides were co-stained with CD11B-AF488.

  B. MATLAB code for the prediction of Pancreatic Cancer (PC) recurrence patterns based on premetastatic liver (PML) derived parameters. Code created by Jayasree Chakraborty, PhD (MSKCC).

