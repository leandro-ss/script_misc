select name, round(sum(mb),1) mb, round(sum(inuse),1) inuse
        from (select case when name = 'buffer_cache'
                          then 'db_cache_size'
                       when name = 'log_buffer'
                         then 'log_buffer'
                        else pool
                     end name,
                 bytes/1024/1024 mb,
                    case when name <> 'free memory'
                    then bytes/1024/1024
                   end inuse
              from v$sgastat
      )group by NAME;