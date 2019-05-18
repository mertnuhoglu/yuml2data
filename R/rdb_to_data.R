main_enum_rdb_to_datafiller_enum_txt = function() {
  data_model_dir = env_data_model_dir()
	evl = read_enum_value(data_model_dir)
  ##>    enum_value_id        enum_value_name enum_var_id
  ##> 1           1000        departure depot           1
  ##> 2           1001           return depot           1
  ##> 3           1002              pick stop           1

	evr = read_enum_var(data_model_dir)
  ##>   enum_var_id   enum_var_name
  ##> 1           1 route_stop_enum
  ##> 2           2     action_enum
  ##> 3           3      place_enum

	evl2 = evl %>%
		dplyr::inner_join(evr, by = "enum_var_id") %>%
		dplyr::select(enum_value_id, enum_var_name)
  ##>    enum_value_id   enum_var_name
  ##> 1           1000 route_stop_enum
  ##> 2           1001 route_stop_enum
  ##> 3           1002 route_stop_enum
	for (en in unique(evl2$enum_var_name)) {
		##> [1] "route_stop_enum"
		vals = dplyr::filter(evl2, enum_var_name == en)$enum_value_id
		##> [1] 1000 1001 1002 1003 1004 1005
		file_path = sprintf("%s/rdb/view/%s.txt", data_model_dir, en)
		##> [1] "/Users/mertnuhoglu/projects/itr/yuml2data_wt/dm/rdb/view/route_stop_enum.txt"
		writeLines(as.character(vals), file_path)
	}
}

main_rdb_to_data = function() {
  data_model_dir = env_data_model_dir()
  entities = c("enum_var", "enum_value")
  input_files = sprintf("%s/rdb/def/%s.xlsx", data_model_dir, entities)
  data_entities = lapply(entities, r_entity, data_model_dir) %>%
    setNames(entities)
  ##> 	data_entities
  ##> $enum_var
  ##>   enum_var_id   enum_var_name
  ##> 1           1 route_stop_enum
  ##> 2           2     action_enum
  ##> 3           3      place_enum
  ##> 
  ##> $enum_value
  ##>    enum_value_id        enum_value_name enum_var_id
  ##> 1           1000        departure depot           1
  ##> 2           1001           return depot           1
  ##> 3           1002              pick stop           1
  ##> 4           1003              drop stop           1
  ##> 5           1004         pick/drop stop           1
  ##> 6           1005 departure/return depot           1
  ##> 7           2000              pick/load           2
  ##> 8           2001            drop/unload           2
  ##> 9           3000                  depot           3
  ##> 10          3001                factory           3
  ##> 11          3002               customer           3

  dfl = read_data_field(data_model_dir)
  ##>     data_field_id               data_field_name        type   pk_fk not_null data_entity_id fk_data_entity_id   enum_var_name
  ##> 1               1            address_variant_id         INT      PK    FALSE              1                NA
  ##> 2               2                    address_id         INT      FK     TRUE              1                 2
  den = read_data_entity(data_model_dir)
  ##>    data_entity_id          entity_name
  ##> 1               1      address_variant
  ##> 2               2              address
  ent_m_cmdtype_m_cmds = lapply( entities, rdb_to_data, data_entities, dfl, den) %>%
    setNames(entities)
  ##> 	ent_m_cmdtype_m_cmds
  ##> List of 2
  ##>  $ enum_var  :List of 4
  ##>   ..$ sql_insert      : chr [1:3] "INSERT INTO enum_var (enum_var_id,enum_var_name) VALUES ('1','route_stop_enum');" "INSERT INTO enum_var (
  ##>   ..$ sql_update      : chr [1:3] "    UPDATE enum_var SET enum_var_name = 'route_stop_enum' WHERE enum_var_id = 1;" "    
	##> ...

  for (entity in names(ent_m_cmdtype_m_cmds)) {
    cmdtype_m_cmds = ent_m_cmdtype_m_cmds[[entity]]
    for (cmdtype in names(cmdtype_m_cmds)) {
       file_path = sprintf("%s/sample_data/%s/%s_%s.sql", data_model_dir, cmdtype, cmdtype, entity)
       dir.create(dirname(file_path), recursive = T)
       writeLines( cmdtype_m_cmds[[cmdtype]], file_path )
    }
  }

  return(input_files)
}

insert_sql_template = function( entity, columns ) {
        template = "INSERT INTO %s (%s) VALUES (%s);"
        column_names = columns %>% paste(collapse=",")
        data_placeholders = rep( "'%s'", length(columns ) ) %>% paste(collapse=",") 
        result = sprintf( template, entity, column_names, data_placeholders )
        return(result)
}

insert_sql = function( data, template ) {
        arg = c( list(template), as.list(data) )
        do.call( 'sprintf', arg ) %>%
                stringr::str_replace_all( "'NA'", "null" )
}

sql_insert = function(df, entity) {
	template_df = dplyr::data_frame( entity = entity, insert_template = insert_sql_template(entity, names(df) ))
	insert_sql( df, template_df$insert_template )
}

delete_sql = function( df, template ) {
        arg = c( list(template), as.list(df) )
        do.call( 'sprintf', arg ) 
}

delete_sql_template = function( entity, id_column) {
        template = "DELETE FROM %s WHERE %s = %%s;"
        sprintf( template, entity, id_column)
}

sql_delete = function(df, entity) {
        template = dplyr::data_frame( entity= entity, delete_template = delete_sql_template(entity, names(df) ))
        delete_sql( df, template$delete_template )
}

update_sql = function( data, template ) {
        arg = c( list(template), as.list(data) )
        do.call( 'sprintf', arg ) %>%
                stringr::str_replace_all( "'\\bNA\\b'", "null" ) 
}

update_sql_template = function( entity, columns ) {
        template = "    UPDATE %s SET %s WHERE %s = %%s;"
        columns_to_set = head(columns, -1)
        set_column_clause = sprintf("%s = '%%s'", columns_to_set) %>% 
                paste(collapse=", ")
  id_column = tail(columns, 1)
        sprintf( template, entity, set_column_clause, id_column )
}

sql_update = function(df, entity) {
        template = dplyr::data_frame( entity= entity, update_template = update_sql_template(entity, names(df) ))
        update_sql( df, template$update_template )
}

build_sql = function(df, entity, id_column, den) {
  df_id_at_end = df %>%
                dplyr::select( -dplyr::one_of(id_column), dplyr::everything(), id_column )
  df_no_fk = dplyr::select( df, -dplyr::ends_with("_id"), id_column) %>%
    dplyr::select( id_column, dplyr::everything() )
  if ( any("invalid" %in% names(df)) ) {
    df_invalid = df %>%
      dplyr::filter( invalid == 1 ) %>%
      dplyr::select(id_column)
  } else {
    df_invalid = df %>%
      dplyr::select(id_column)
  }
  list(
       sql_insert = sql_insert( df, entity )
       , sql_update = sql_update( df_id_at_end, entity )
       , sql_insert_no_fk = sql_insert( df_no_fk, entity )
       , sql_delete = sql_delete( df_invalid, entity )
       )
}

rdb_to_data = function(entity, data_entities, dfl, den) {
	entity
  ##> [1] "enum_var"
  dflf = dfl %>%
    dplyr::left_join(den, by = "data_entity_id") %>%
    dplyr::filter(entity_name == entity) 
  ##>   data_field_id data_field_name type   pk_fk not_null data_entity_id fk_data_entity_id enum_var_name entity_name
  ##> 1            29     enum_var_id  INT      PK    FALSE              8                NA                  enum_var
  ##> 2            30   enum_var_name TEXT NON_KEY    FALSE              8                NA                  enum_var
  columns = dflf$data_field_name
  id_column = dflf %>%
    dplyr::filter(pk_fk == "PK") %>%
    magrittr::extract2("data_field_name")
  ##> [1] "enum_var_id"
	df = data_entities[[entity]] %>%
    dplyr::select_(.dots = columns)
  ##>   enum_var_id   enum_var_name
  ##> 1           1 route_stop_enum
  ##> 2           2     action_enum
  ##> 3           3      place_enum
	build_sql(df, entity, id_column, den)
  ##> List of 4
  ##>  $ sql_insert      : chr [1:3] "INSERT INTO enum_var (enum_var_id,enum_var_name) VALUES ..
  ##>  $ sql_update      : chr [1:3] "    UPDATE enum_var SET enum_var_name = 'route_stop_enum' WHERE enum_var_id = 1;" "    UPDATE enum
}

