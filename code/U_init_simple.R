U0 = matrix(0,p,p)
U1 = U0; U1[1,1] = 1
U2 = U0; U2[c(1:2), c(1:2)] = 1
U3 = matrix(1, p,p)
Utrue = list(U0 = U0, U1 = U1, U2 = U2, U3 = U3)
Vtrue = clusterGeneration::rcorrmatrix(p)

# You can make multiple-page PDF file here
pdf(debug_plots)
heatmap(Vtrue)
heatmap(Vtrue)
dev.off()
