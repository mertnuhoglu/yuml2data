#' @export
r_datamodel_sdb = function(data_model_dir = env_data_model_dir()) {
	readLines(sprintf("%s/rdb/view/datamodel_sdb.yuml", data_model_dir))
}

read_yuml_data_model = function(data_model_dir = env_data_model_dir()) {
  readr::read_csv(sprintf("%s/rdb/view/yuml_data_model.csv", data_model_dir))
}

write_yuml_data_model = function(df, data_model_dir = env_data_model_dir()) {
  rio::export(df, sprintf("%s/rdb/view/yuml_data_model.csv", data_model_dir))
}

read_enum_value = function(data_model_dir = env_data_model_dir()) {
  rio::convert(sprintf("%s/rdb/def/enum_value.xlsx", data_model_dir), sprintf("%s/rdb/def/enum_value.tsv", data_model_dir))
  rio::import(sprintf("%s/rdb/def/enum_value.xlsx", data_model_dir))
}

write_enum_value = function(df, data_model_dir = env_data_model_dir()) {
  rio::export(df, sprintf("%s/rdb/def/enum_value.xlsx", data_model_dir))
  rio::convert(sprintf("%s/rdb/def/enum_value.xlsx", data_model_dir), sprintf("%s/rdb/def/enum_value.tsv", data_model_dir))
}

read_enum_var = function(data_model_dir = env_data_model_dir()) {
  rio::convert(sprintf("%s/rdb/def/enum_var.xlsx", data_model_dir), sprintf("%s/rdb/def/enum_var.tsv", data_model_dir))
  rio::import(sprintf("%s/rdb/def/enum_var.xlsx", data_model_dir))
}

write_enum_var = function(df, data_model_dir = env_data_model_dir()) {
  rio::export(df, sprintf("%s/rdb/def/enum_var.xlsx", data_model_dir))
  rio::convert(sprintf("%s/rdb/def/enum_var.xlsx", data_model_dir), sprintf("%s/rdb/def/enum_var.tsv", data_model_dir))
}

r_entity = function(entity, data_model_dir = env_data_model_dir()) {
  rio::import(sprintf("%s/rdb/def/%s.xlsx", data_model_dir, entity))
}

r_data_entity = function(...) {
  read_data_entity(...)
}

read_data_entity = function(data_model_dir = env_data_model_dir()) {
  rio::import(sprintf("%s/rdb/view/data_entity.tsv", data_model_dir))
}

write_data_entity = function(df, data_model_dir = env_data_model_dir()) {
  rio::export(df, sprintf("%s/rdb/view/data_entity.tsv", data_model_dir))
}

r_data_field = function(...) {
  read_data_field(...)
}

read_data_field = function(data_model_dir = env_data_model_dir()) {
  rio::import(sprintf("%s/rdb/view/data_field.tsv", data_model_dir))
}

write_data_field = function(df, data_model_dir = env_data_model_dir()) {
  rio::export(df, sprintf("%s/rdb/view/data_field.tsv", data_model_dir))
}

