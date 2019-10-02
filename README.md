# Urine-patches-detection
This project is dedicated to making the code used for the data of this article: Identifying Urine Patches on Intensively Managed Grassland Using Aerial Imagery Captured From Remotely Piloted Aircraft Systems https://www.frontiersin.org/articles/10.3389/fsufs.2018.00010/full available to everyone.

Juliette Maire led the project as part of her Ph.D. to investigate the possibility and efficiency of detecting urine patches from images captured using Remotely Piloted Aircraft System. A urine patch is a visual delimitation between the grass that responded to an input of urine and the rest of the field. The urine patch includes two elements: 1) the wetted area where the urine was applied 2) the effective area which combines the wetted area and where the grass has had access to the urinary nitrogen through their root or where the nitrogen diffused through the soil pores. The grass inside the effective area of a patch is greener, darker and higher. These areas can be detected using RGB and NIR cameras mounted on an RPAS. To automate the patch detection, the K-means method was implemented in the R script.The advantage of this algorithm is that it has low computational complexity, it is an unsupervised learning mechanism and the resulted clusters of this method are not overlapping.

In this project, RPAS and R image analysis have proven to be effective when carrying out high-resolution, non-destructive, near real-time, and low-cost assessment of the size and distribution of urine patches from aerial surveys. Using low-cost RPAS, onboard cameras, and open-source software, this method offers new perspectives for nutrient management, precision agriculture, and greenhouse gas emissions estimation in grassland systems.

Funded by the Walsh fellowship program by Teagasc, Ireland, the BBSRC–Newton project UK-China Virtual Joint Centre for Improved Nitrogen Agronomy (CINAG) and UK-SCAPE.

For more information read the article mentioned above.
