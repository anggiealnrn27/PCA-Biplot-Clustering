####PCA-BIPLOT DENGAN SVD####
###MENGAKTIFKAN LIBRARY###
library(MVN)

###IMPORT DATA###
setwd("C:/Users/USER/OneDrive/Magang BPS/Clustering")
data <- read.csv("Data Analisis Sakernas 2023.csv", sep=";", dec=".")
head(data)
str(data)

# Mengubah variabel X1–X16 menjadi numeric
data[, 2:17] <- lapply(data[, 2:17], function(x) as.numeric(as.character(x)))
# Cek kembali struktur data
str(data)

###PENDETEKSIAN OUTLIER UNIVARIAT###
find_outliers <- function(x) {
  Q1 <- quantile(x, 0.25)
  Q3 <- quantile(x, 0.75)
  IQR_value <- Q3 - Q1
  lower_bound <- Q1 - 1.5 * IQR_value
  upper_bound <- Q3 + 1.5 * IQR_value
  x[x < lower_bound | x > upper_bound]
}

outliers <- lapply(data[-1], find_outliers)
names(outliers) <- colnames(data[-1])
print(outliers)

###STANDARISASI DATA###
ZScore <- as.data.frame(scale(data[-1]))
X <- as.matrix(ZScore)

###PENGECEKAN NORMALITAS DAN OUTLIER MULTIVARIAT###
Mardia_Test <- mvn(data = ZScore, mvn_test = "mardia")
print(Mardia_Test)

###SINGULAR VALUE DECOMPOSITION###
##MENCARI NILAI EIGEN DAN VEKTOR EIGEN MATRIKS X##
XTX <- t(X) %*% X
eigen_values <- eigen(XTX)

##MENCARI MATRIKS L##
EVAL <- eigen_values$values
L <- diag(sqrt(EVAL))

##MENCARI MATRIKS A##
A <- eigen_values$vectors

##MENCARI MATRIKS U##
U <- X %*% A %*% solve(L)

###MENENTUKAN JUMLAH KOMPONEN UTAMA###
PCA <- prcomp(X, scale. = TRUE)
print(summary(PCA))

###KOORDINAT BIPLOT###
alpha <- 0.5
G <- U %*% L^alpha
H <- t(L^(1 - alpha) %*% t(A))
G14 <- G[, 1:4]
H14 <- H[, 1:4]

###PETA PENGELOMPOKAN###
#biplot(G12, H12, xlab = "PC1 = 52.49 %", ylab = "PC2 = 22.10 %", cex = 0.6)
#abline(h = 0, v = 0)

###MATRIKS KORELASI COSINUS###
Cos_Cor <- function(x) {
  p <- nrow(x)
  y <- matrix(0, nrow = p, ncol = p)
  for (i in 1:p) {
    for (j in 1:p) {
      y[i, j] <- sum(x[i, ] * x[j, ]) / 
        (sqrt(sum(x[i, ]^2)) * sqrt(sum(x[j, ]^2)))
    }
  }
  return(y)
}
Cos_Cor(H14)

### MATRIKS NILAI VARIABEL PADA SUATU OBJEK ###
Cos_Cor_var <- function(x, y) {
  p <- nrow(x)   # jumlah objek
  q <- nrow(y)   # jumlah variabel
  z <- matrix(0, nrow = p, ncol = q)
  for (i in 1:p) {
    for (j in 1:q) {
      z[i, j] <- sum(x[i, ] * y[j, ]) / 
        (sqrt(sum(x[i, ]^2)) * sqrt(sum(y[j, ]^2)))
    }
  }
  return(z)
}
Cos_Cor_var(G14, H14)

####CLUSTERING####
###MENGAKTIFKAN LIBRARY###
library(dendextend)
library(NbClust)
library(geometry)

###MENGHITUNG JARAK###
Cosine_Distance <- function(x) {
  n <- nrow(x)
  dist_matrix <- matrix(0, nrow = n, ncol = n)
  for (i in 1:n) {
    for (j in 1:n) {
      cosine_similarity <- dot(x[i,], x[j,]) / (sqrt(sum(x[i,]^2)) * sqrt(sum(x[j,]^2)))
      dist_matrix[i, j] <- 1 - cosine_similarity
    }
  }
  as.dist(dist_matrix)
}
Dist <- Cosine_Distance(G14)

###ANALISIS AGGLOMERATIVE HIERARCHICAL CLUSTERING###
cluster_analysis <- function(method) {
  fit <- hclust(Dist, method = method)
  dend <- as.dendrogram(fit)
  dend_colored <- color_branches(dend)
  plot(dend_colored, main = paste("Dendrogram -", method))
  cor_val <- cor(Dist, cophenetic(fit))
  list(fit = fit, cor = cor_val)
}
methods <- c("single", "complete", "average", "ward.D", "centroid")
results <- lapply(methods, cluster_analysis)
names(results) <- methods

##PEMILIHAN METODE CLUSTERING##
cor_values <- sapply(results, function(res) res$cor)
print(cor_values)

##MENENTUKAN JUMLAH CLUSTER##
optimal_clusters <- NbClust(data = G14, diss = Dist, distance = NULL, 
                            min.nc = 2, max.nc = 5, method = "average",
                            index = "dunn", alphaBeale = 0.1)
print(optimal_clusters)

##CLUSTER TERPILIH##
final_fit <- results[["average"]]$fit
Cluster <- data.frame(Provinsi = data[, 1], 
                      Cluster = cutree(final_fit, k = 4))
print(Cluster)

##PLOT DENDOGRAM FINAL##
plot(final_fit, main = "Final Dendrogram - Average Method")
rect.hclust(final_fit, k = 4)

#============ ANALISIS PROFIL ============
da=read.csv("data cluster 1.csv",sep=";", dec=".")
db=read.csv("data cluster 2.csv",sep=";", dec=".")
dc=read.csv("data cluster 3.csv",sep=";", dec=".")
dd=read.csv("data cluster 4.csv",sep=";", dec=".")
attach(da)
str(da)
attach(db)
attach(dc)
attach(dd)

#====================================================
# HITUNG MEAN VEKTOR (y1 - y4)
#====================================================

y1 = matrix(colMeans(da[,-1]))
y2 = matrix(colMeans(db[,-1]))
y3 = matrix(colMeans(dc[,-1]))
y4 = matrix(colMeans(dd[,-1]))

y1
y2
y3
y4

#====================================================
# UKURAN SAMPEL
#====================================================
n11 = nrow(da)
n21 = nrow(db)
n31 = nrow(dc)
n41 = nrow(dd)

p = 16
alpha = 0.05

#====================================================
# VARKOV (CARA CEPAT)
#====================================================
S1 = cov(da[,-1])
S2 = cov(db[,-1])
S3 = cov(dc[,-1])
S4 = cov(dd[,-1])

S1
S2
S3
S4


Sgab = ((n11-1)*S1 +
          (n21-1)*S2 +
          (n31-1)*S3 +
          (n41-1)*S4) /
  (n11+n21+n31+n41-4)
Sgab
#====================================================
# MATRIKS KONTRAS (4 CLUSTER)
#====================================================
C = matrix(0, nrow=3, ncol=16)

C[1,1] = 1
C[1,2] = -1

C[2,2] = 1
C[2,3] = -1

C[3,3] = 1
C[3,4] = -1

C
# CEK DIMENSI (PENTING)
dim(C)
dim(Sgab)

A=C%*%Sgab%*%t(C)
A
#Menghitung C(y1-y2)
Ybar = cbind(y1,y2,y3,y4)
Ybar
B=C%*%Ybar
B
Ntotal = n11 + n21 + n31 + n41
D = solve(A)
D
Tmat = t(B) %*% D %*% B
Tkuadrat = Ntotal * sum(diag(Tmat))
Tkuadrat
ftabel = qf((1-alpha),
            p,
            Ntotal-4-p+1)
ftabel
ckuadrat = (((Ntotal-4)*p) /
              (Ntotal-4-p+1)) * ftabel
ckuadrat
#untuk 4 klaster yang terbentuk pada data sakernas tidak berhimpit 
#sehingga tidak perlu dilakukan analisis berikutnya 
#karena sudah pasti tidak ada kesamaan.

m1 = colMeans(da[,-1])
m2 = colMeans(db[,-1])
m3 = colMeans(dc[,-1])
m4 = colMeans(dd[,-1])

mean_cluster = rbind(
  Cluster1 = m1,
  Cluster2 = m2,
  Cluster3 = m3,
  Cluster4 = m4
)

mean_cluster
mean_std = scale(mean_cluster)
mean_std
#write.csv(
#  mean_std,
#  "profil_cluster.csv"
#)
