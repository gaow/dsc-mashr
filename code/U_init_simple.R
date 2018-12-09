U0 = matrix(0,p,p)
U1 = U0; U1[1,1] = 1
U2 = U0; U2[c(2:3), c(2:3)] = 1
U3 = diag(p)
Utrue = list(U0 = U0, U1 = U1, U2 = U2, U3 = U3)
Vtrue = clusterGeneration::rcorrmatrix(p)

# You can make multiple-page PDF file here
pdf(debug_plots)
corrplot::corrplot(Vtrue, method='color', cl.lim=c(-1,1), type='upper', addCoef.col = "black", tl.col="black", tl.srt=45,
                   col=colorRampPalette(rev(c("#D73027","#FC8D59","#FEE090","#FFFFBF", "#E0F3F8","#91BFDB","#4575B4")))(128))
dev.off()
