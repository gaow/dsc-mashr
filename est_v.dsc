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

mle (current): R(V = mashr::estimate_null_correlation_mle($(m_data), $(Ulist), max_iter = max_iter, tol = tol))
mle_em (current): R(V = mashr::estimate_null_correlation_mle_em($(m_data), $(Ulist), max_iter = max_iter, tol = tol))

DSC:
    define: 
        estimate: simple, current, mle, mle_em
    run: simulate * estimate
    replicate: 50
    R_libs: assertthat, MASS, mashr@zouyuxin/mashr, clusterGeneration
    exec_path: code
    output: est_v
