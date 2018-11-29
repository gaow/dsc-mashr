generate_data = function(n, p, V, Utrue, pi=NULL){
  if (is.null(pi)) {
    pi = rep(1, length(Utrue)) # default to uniform distribution
  }
  assertthat::are_equal(length(pi), length(Utrue))

  for (j in 1:length(Utrue)) {
    assertthat::are_equal(dim(Utrue[j]), c(p, p))
  }

  pi <- pi / sum(pi) # normalize pi to sum to one
  which_U <- sample(1:length(pi), n, replace=TRUE, prob=pi)

  Beta = matrix(0, nrow=n, ncol=p)
  for(i in 1:n){
    Beta[i,] = MASS::mvrnorm(1, rep(0, p), Utrue[[which_U[i]]])
  }

  E = MASS::mvrnorm(n, rep(0, p), V)
  Bhat = Beta + E
  Shat = 1
  return(list(B = Beta, Bhat=Bhat, Shat = Shat))
}