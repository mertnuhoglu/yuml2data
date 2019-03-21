
main_yuml_to_uml = function() {
  data_model_dir = env_data_model_dir()
  main_yuml_to_uml.sh = system.file("bash/main_yuml_to_uml.sh", package = "yuml2data")
  input_files = system2(main_yuml_to_uml.sh, data_model_dir, stdout=TRUE)
  return(input_files)
}
