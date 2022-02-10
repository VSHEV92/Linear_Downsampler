# ------------------------------------------------------
# ------ Cкрипт для автоматической упаковки ядра -------
# ------------------------------------------------------

# -----------------------------------------------------------
set Project_Name temp_project

# создаем временный проект проект
create_project $Project_Name ./$Project_Name -part xcku060-ffva1156-2-e

# настраиваем AXI-интерфейс
update_compile_order -fileset sources_1
create_peripheral xilinx.com user Linear_Downsampler 1.0 -dir .
add_peripheral_interface S_AXI -interface_mode slave -axi_type lite [ipx::find_open_core xilinx.com:user:Linear_Downsampler:1.0]
generate_peripheral -driver -bfm_example_design -debug_hw_example_design [ipx::find_open_core xilinx.com:user:Linear_Downsampler:1.0]
write_peripheral [ipx::find_open_core xilinx.com:user:Linear_Downsampler:1.0]
set_property  ip_repo_paths Linear_Downsampler_1.0 [current_project]
update_ip_catalog -rebuild
ipx::edit_ip_in_project -upgrade true -name Linear_Downsampler_v1_0_project -directory temp_project/temp_project.tmp/Linear_Downsampler_v1_0_project Linear_Downsampler_1.0/component.xml
set_property vendor vshev92 [ipx::current_core]
set_property supported_families {kintexu Pre-Production artix7 Beta artix7l Beta qartix7 Beta qkintex7 Beta qkintex7l Beta kintexu Beta kintexuplus Beta qvirtex7 Beta virtexuplus Beta virtexuplusHBM Beta qzynq Beta zynquplus Beta kintex7 Beta kintex7l Beta spartan7 Beta versal Beta virtex7 Beta virtexu Beta virtexuplus58g Beta aartix7 Beta akintex7 Beta aspartan7 Beta azynq Beta zynq Beta} [ipx::current_core]

# удаляем автоматически сгенерированные файлы
export_ip_user_files -of_objects  [get_files Linear_Downsampler_1.0/hdl/Linear_Downsampler_v1_0.v] -no_script -reset -force -quiet
export_ip_user_files -of_objects  [get_files Linear_Downsampler_1.0/hdl/Linear_Downsampler_v1_0_S_AXI.v] -no_script -reset -force -quiet
remove_files  {Linear_Downsampler_1.0/hdl/Linear_Downsampler_v1_0.v Linear_Downsampler_1.0/hdl/Linear_Downsampler_v1_0_S_AXI.v}

# добавляем файлы исходников
add_files -norecurse -copy_to Linear_Downsampler_1.0/src {source_hdl/Linear_Downsampler_v1_0_S_AXI.v source_hdl/Linear_Downsampler_v1_0.v}
add_files -norecurse -copy_to Linear_Downsampler_1.0/src source_hdl/downsampler_core.sv
update_compile_order -fileset sources_1
ipx::merge_project_changes files [ipx::current_core]
ipx::merge_project_changes hdl_parameters [ipx::current_core]

# добавляем Slave AXI Stream
ipx::add_bus_interface S_AXIS [ipx::current_core]
set_property abstraction_type_vlnv xilinx.com:interface:axis_rtl:1.0 [ipx::get_bus_interfaces S_AXIS -of_objects [ipx::current_core]]
set_property bus_type_vlnv xilinx.com:interface:axis:1.0 [ipx::get_bus_interfaces S_AXIS -of_objects [ipx::current_core]]
ipx::add_port_map TDATA [ipx::get_bus_interfaces S_AXIS -of_objects [ipx::current_core]]
set_property physical_name indata_tdata [ipx::get_port_maps TDATA -of_objects [ipx::get_bus_interfaces S_AXIS -of_objects [ipx::current_core]]]
ipx::add_port_map TVALID [ipx::get_bus_interfaces S_AXIS -of_objects [ipx::current_core]]
set_property physical_name indata_tvalid [ipx::get_port_maps TVALID -of_objects [ipx::get_bus_interfaces S_AXIS -of_objects [ipx::current_core]]]
ipx::add_port_map TREADY [ipx::get_bus_interfaces S_AXIS -of_objects [ipx::current_core]]
set_property physical_name indata_tready [ipx::get_port_maps TREADY -of_objects [ipx::get_bus_interfaces S_AXIS -of_objects [ipx::current_core]]]

# добавляем Master AXI Stream
ipx::add_bus_interface M_AXIS [ipx::current_core]
set_property abstraction_type_vlnv xilinx.com:interface:axis_rtl:1.0 [ipx::get_bus_interfaces M_AXIS -of_objects [ipx::current_core]]
set_property bus_type_vlnv xilinx.com:interface:axis:1.0 [ipx::get_bus_interfaces M_AXIS -of_objects [ipx::current_core]]
set_property interface_mode master [ipx::get_bus_interfaces M_AXIS -of_objects [ipx::current_core]]
ipx::add_port_map TDATA [ipx::get_bus_interfaces M_AXIS -of_objects [ipx::current_core]]
set_property physical_name outdata_tdata [ipx::get_port_maps TDATA -of_objects [ipx::get_bus_interfaces M_AXIS -of_objects [ipx::current_core]]]
ipx::add_port_map TVALID [ipx::get_bus_interfaces M_AXIS -of_objects [ipx::current_core]]
set_property physical_name outdata_tvalid [ipx::get_port_maps TVALID -of_objects [ipx::get_bus_interfaces M_AXIS -of_objects [ipx::current_core]]]
ipx::add_port_map TREADY [ipx::get_bus_interfaces M_AXIS -of_objects [ipx::current_core]]
set_property physical_name outdata_tready [ipx::get_port_maps TREADY -of_objects [ipx::get_bus_interfaces M_AXIS -of_objects [ipx::current_core]]]

ipx::associate_bus_interfaces -busif S_AXIS -clock aclk [ipx::current_core]
ipx::associate_bus_interfaces -busif M_AXIS -clock aclk [ipx::current_core]

# пакуем ядро
update_compile_order -fileset sources_1
set_property previous_version_for_upgrade xilinx.com:user:Linear_Downsampler:1.0 [ipx::current_core]
set_property core_revision 1 [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::check_integrity [ipx::current_core]
ipx::save_core [ipx::current_core]
ipx::move_temp_component_back -component [ipx::current_core]
close_project -delete
update_ip_catalog -rebuild -repo_path Linear_Downsampler_1.0

# удаляем временный проект
close_project -delete
file delete -force temp_project
