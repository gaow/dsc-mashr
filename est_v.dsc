#!/usr/bin/env dsc

simulate: utils.R + generate_data.R
    n: 4000
    p: 5
    $m_data: m.data
    $v_true: V.true
    $data: data
    $Ulist: Ulist

simple: R(V = list();
          V$V = mashr::estimate_null_correlation_simple($(m_data)); 
          simple_data = mashr::mash_update_data($(m_data), V = V$V);
          V$mash.model = mashr::mash(simple_data, $(Ulist)))
    $V: V

current: R(V = mashr::estimate_null_correlation($(m_data), $(Ulist), max_iter = max_iter, tol = tol))
    max_iter: 100
    tol: 1e-2
    $V: V

mle (current): R(V = mashr::estimate_null_correlation_mle($(m_data), $(Ulist), max_iter = max_iter, tol = tol);
		 mle_data = mashr::mash_update_data($(m_data), V = V$V);
		 V$mash.model$result = mash_compute_posterior_matrices(V$mash.model, mle_data)$result)

mle_em (current): R(V = mashr::estimate_null_correlation_mle_em($(m_data), $(Ulist), max_iter = max_iter, tol = tol))

mashloglik: R( loglik = c(get_loglik($(v_true)$m.model), get_loglik($(V)$mash.model)))
   $loglik: loglik

FrobeniusNorm: R(error = norm($(V)$V, $(v_true)$V, type='F'))
   $error: error

ROC: R(ROC.table = function(data, model){
                       sign.test = data*model$result$PosteriorMean;
                       thresh.seq = seq(0, 1, by=0.005)[-1];
                       m.seq = matrix(0,length(thresh.seq), 2);
                       colnames(m.seq) = c('TPR', 'FPR');
                       for(t in 1:length(thresh.seq)){
                           m.seq[t,] = c(sum(sign.test>0 & model$result$lfsr <= thresh.seq[t])/sum(data!=0),
                           sum(data==0 & model$result$lfsr <=thresh.seq[t])/sum(data==0));
                       }
                       return(m.seq);
       };
       roc_seq = ROC.table($(data)$B, $(V)$mash.model);
       true_seq = ROC.table($(data)$B, $(v_true)$m.model);
       ROCs = cbind(true_seq, roc_seq))
   $roc: ROCs

RRMSE: R(rrmse = c(sqrt( mean( ($(data)$B - $(v_true)$m.model$result$PosteriorMean)^2 )/mean( ($(data)$B - $(data)$Bhat)^2 )), 
                   sqrt(mean(($(data)$B - $(V)$mash.model$result$PosteriorMean)^2)/mean(($(data)$B - $(data)$Bhat)^2))))
   $rrmse: rrmse

DSC:
    define: 
        estimate: simple, current, mle, mle_em
	summary: mashloglik, FrobeniusNorm, ROC, RRMSE
    run: simulate * estimate * summary
    replicate: 50
    R_libs: assertthat, MASS, mashr@zouyuxin/mashr, clusterGeneration
    exec_path: code
    output: est_v
