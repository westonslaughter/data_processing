
#retrieval kernels ####

#discharge: STATUS=READY
#. handle_errors
process_0_VERSIONLESS001 <- download_from_googledrive

#stream_chemistry: STATUS=READY
#. handle_errors
process_0_VERSIONLESS002 <- download_from_googledrive

#munge kernels ####

#discharge: STATUS=READY
#. handle_errors
process_1_VERSIONLESS001 <- function(network, domain, prodname_ms, site_code, component) {

    browser()

    rawfile <- glue('data/{n}/{d}/raw/{p}/{s}/discharge.xlsx',
                    n = network,
                    d = domain,
                    p = prodname_ms,
                    s = site_code)

    raw_xlsx <- readxl::read_xlsx(rawfile) %>%
      mutate(
        site_code = 'trout_brook'
      ) %>%
      rename(
        discharge = 'Discharge (cfs)...8'
      )

    # hey! if this kernel is being run again, make sure to check the flag columns
    # in the original data, as there may be new flag info
    d <- ms_read_raw_csv(preprocessed_tibble = raw_xlsx,
                         datetime_cols = list('Date' = '%Y-%m-%d %H:%M:%S'),
                         datetime_tz = 'America/Chicago',
                         site_code_col = 'site_code',
                         data_cols =  c('discharge'),
                         data_col_pattern = '#V#',
                         # sampling regime:
                         # sensor vs non-sensor
                         # installed (IS) vs grab (GN)
                         is_sensor = TRUE
                         ## summary_flagcols = c('ESTCODE', 'EVENT_CODE')
                         )

    d <- ms_cast_and_reflag(d,
                            varflag_col_pattern = NA
                            )

    #convert cfs to liters/s
    # NOTE: we should have handling?
    d <- d %>%
        mutate(val = val * 28.317)

    d <- qc_hdetlim_and_uncert(d, prodname_ms = prodname_ms)

    # conforming time interval to daily
    d <- synchronize_timestep(d)

    sites <- unique(d$site_code)

    d_site <- d %>%
        filter(site_code == !!sites[s])

    write_ms_file(d = d_site,
                      network = network,
                      domain = domain,
                      prodname_ms = prodname_ms,
                      site_code = sites[s],
                      level = 'munged',
                      shapefile = FALSE)
    return()
}

#stream_chemistry: STATUS=READY
#. handle_errors
process_1_VERSIONLESS002 <- function(network, domain, prodname_ms, site_code, component) {

    rawfile <- glue('data/{n}/{d}/raw/{p}/{s}/stream_chemistry.xlsx',
                    n = network,
                    d = domain,
                    p = prodname_ms,
                    s = site_code)

    header <- readxl::read_xlsx(rawfile, n_max = 1)
    raw_xlsx <- readxl::read_xlsx(rawfile, skip = 1) %>%
      slice(2:nrow(.)) %>%
      mutate(
        site_code = 'trout_brook'
      )

    # NOTE: duplicate column names for value and flag
    colnames(raw_xlsx) <- colnames(header)

    d <- ms_read_raw_csv(preprocessed_tibble =  raw_xlsx,
                         datetime_cols = list('Date' = '%Y-%m-%d %H:%M:%S'),
                         datetime_tz = 'America/Chicago',
                         site_code_col = 'site_code',
                         data_cols =  c(pH='pH',
                                        `Specific conductance (mg/l)` = 'spCond',
                                        # NOTE: Phosphate?
                                        ## `Phosphorus as P (mg/l)` = 'P',
                                        `Nitrate (NO3) as N (mg/l)` = 'NO3_N'
                                        ),
                         data_col_pattern = '#V#',
                         is_sensor = FALSE,
                         set_to_NA = '',
                         var_flagcol_pattern = '#V#CODE',
                         summary_flagcols = c('TYPE'))

    d <- ms_cast_and_reflag(d,
                            variable_flags_to_drop = 'N',
                            variable_flags_dirty = c('*', 'Q', 'D*', 'C', 'D', 'DE',
                                                     'DQ', 'DC'),
                            variable_flags_clean =
                                c('A', 'E'),
                            summary_flags_to_drop = list(
                                TYPE = c('N', 'YE')),
                            summary_flags_dirty = list(
                                TYPE = c('C', 'S', 'A', 'P', 'B')
                            ),
                            summary_flags_clean = list(TYPE = c('QB', 'QS', 'QL',
                                                                'QA', 'F', 'G')))

    d <- qc_hdetlim_and_uncert(d, prodname_ms = prodname_ms)

    d <- synchronize_timestep(d)

    unlink(temp_dir, recursive = TRUE)

    sites <- unique(d$site_code)

    for(s in 1:length(sites)){

        d_site <- d %>%
            filter(site_code == !!sites[s])

        write_ms_file(d = d_site,
                      network = network,
                      domain = domain,
                      prodname_ms = prodname_ms,
                      site_code = sites[s],
                      level = 'munged',
                      shapefile = FALSE)
    }

    return()
}

#derive kernels ####

#stream_flux_inst: STATUS=READY
#. handle_errors
process_2_ms001 <- derive_stream_flux
