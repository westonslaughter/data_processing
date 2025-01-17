xx = tibble(date = c('2010-01-01', '2010-01-02', '2010-01-03', '2010-01-04'),
            site = c('a', 'a', 'b', 'b'),
            w = c(NA, NA, NA, NA),
            x = c('bd', 'BDL', '4', NA),
            y = c(NA, NA, NA, NA),
            z = c('BDL', NA, '5', NA),
            # wflg = c(NA, NA, NA),
            xflg = c(NA, NA, NA, NA),
            yflg = c(NA, 'BDL', 'aa', NA),
            zflg = c('BDL', NA, NA, NA),
            overallflg = c(NA, 'BDL', NA, 'BDL'))

ms_read_raw_csv(preprocessed_tibble = xx,
                datetime_cols = list('date' = '%Y-%m-%d'),
                datetime_tz = 'America/New_York',
                site_code_col = 'site',
                data_cols =  c(w = 'NH4',
                               x = 'temp',
                               y = 'Cl',
                               z = 'Ca'),
                data_col_pattern = '#V#',
                var_flagcol_pattern = '#V#flg',
                summary_flagcols = 'overallflg',
                is_sensor = FALSE,
                convert_to_BDL_flag = c('BDL', '<3.2', 'bd'))

ms_read_raw_csv(preprocessed_tibble = xx,
                datetime_cols = list('date' = '%Y-%m-%d'),
                datetime_tz = 'America/New_York',
                site_code_col = 'site',
                data_cols =  c(w = 'NH4',
                               x = 'temp',
                               y = 'Cl',
                               z = 'Ca'),
                data_col_pattern = '#V#',
                var_flagcol_pattern = '#V#flg',
                # summary_flagcols = 'overallflg',
                is_sensor = FALSE,
                convert_to_BDL_flag = c('BDL', '<3.2', 'bd'))
