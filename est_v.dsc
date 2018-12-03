#!/usr/bin/env dsc

simulate_simple: utils.R + U_init_simple.R + mash_init.R
    n: 4000
    p: 5
    debug_plots: file(pdf)
    $m_data: m.data
    $v_true: Vtrue
    $data: data
    $Ulist: Ulist

simulate_toy (simulate_simple):
    n: 400
    p: 2

simple: R(V = list();
          V$V = mashr::estimate_null_correlation_simple($(m_data)); 
          simple_data = mashr::mash_update_data($(m_data), V = V$V);
          V$mash.model = mashr::mash(simple_data, $(Ulist))) \
          + plot_mash.R
    debug_plots: file(pdf)
    $V: V

current: R(V = mashr::estimate_null_correlation($(m_data), $(Ulist), max_iter = max_iter, tol = tol)) \
          + plot_mash.R
    max_iter: 100
    tol: 1e-2
    debug_plots: file(pdf)
    $V: V

oracle: R(V = list();
          V$V = $(v_true);
          simple_data = mashr::mash_update_data($(m_data), V = V$V);
          V$mash.model = mashr::mash(simple_data, $(Ulist))) \
          + plot_mash.R
    debug_plots: file(pdf)
    $V: V

mle (current): R(V = mashr::estimate_null_correlation_mle($(m_data), $(Ulist), max_iter = max_iter, tol = tol);
		 mle_data = mashr::mash_update_data($(m_data), V = V$V);
		 V$mash.model$result = mashr::mash_compute_posterior_matrices(V$mash.model, mle_data)$result) \
          + plot_mash.R

mle_em (current): R(V = mashr::estimate_null_correlation_mle_em($(m_data), $(Ulist), max_iter = max_iter, tol = tol)) \
          + plot_mash.R

mashloglik: R(loglik = ashr::get_loglik($(V)$mash.model))
   $score: loglik

FrobeniusNorm: R(error = norm($(V)$V - $(v_true), type='F'))
   $score: error

RRMSE: R(rrmse = sqrt(mean(($(data)$B - $(V)$mash.model$result$PosteriorMean)^2)/mean(($(data)$B - $(data)$Bhat)^2)))
   $score: rrmse

# This is separated from above summary functions because the query results will be neater this way
ROC: ROC_table.R + R(roc_seq = ROC.table($(data)$B, $(V)$mash.model))
   $data: roc_seq

DSC:
    define: 
        simulate: simulate_simple
        estimate: oracle, simple, current, mle
        summary: mashloglik, FrobeniusNorm, RRMSE
    run:
        default: simulate * estimate * (summary, ROC)
        toy: simulate_toy * estimate * (summary, ROC)
    replicate: 2
    R_libs: assertthat, MASS, mashr@zouyuxin/mashr, clusterGeneration
    exec_path: code
    output: est_v
