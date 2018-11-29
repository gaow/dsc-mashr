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
		 V$mash.model$result = mash_compute_posterior_matrices(mle_data, V$mash.model))

mle_em (current): R(V = mashr::estimate_null_correlation_mle_em($(m_data), $(Ulist), max_iter = max_iter, tol = tol))

mashloglik: R(loglik = get_loglik($(V)$mash.model);
              loglik_true =  get_loglik($(v_true)$m.model))
   $loglik: loglik
   $true_loglik: loglik_true

FrobeniusNorm: R(error = norm($(V)$V, $(v_true)$V, type='F'))
   $error: error

ROC: R(roc_seq = ROC.table($(data)$B, $(V)$mash.model);
       true_seq = ROC.table($(data)$B, $(v_true)$m.model))
   $roc: roc_seq
   $true_roc: true_seq

RRMSE: R(rrmse = sqrt(mean(($(data)$B - $(V)$mash.model$result$PosteriorMean)^2)/mean(($(data)$B - $(data)$Bhat)^2));
         rrmse_true = sqrt(mean(($(data)$B - $(v_true)$m.model$result$PosteriorMean)^2)/mean(($(data)$B - $(data)$Bhat)^2)))
   $rrmse: rrmse
   $true_rrmse: rrmse_true

DSC:
    define: 
        estimate: simple, current, mle, mle_em
    run: simulate * estimate
    replicate: 50
    R_libs: assertthat, MASS, mashr@zouyuxin/mashr, clusterGeneration
    exec_path: code
    output: est_v
