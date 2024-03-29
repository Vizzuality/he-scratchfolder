# -*- coding: utf-8 -*-
"""
Generated by ArcGIS ModelBuilder on : 2021-09-10 16:03:22
"""
import arcpy
from sys import argv

def ZsatMajority(geometry="mammal_test", crf_name="elu_Subset.crf", output_table="C:\\Users\\Viz1\\Documents\\ArcGIS\\Projects\\SuperSample\\SuperSample.gdb\\ZonalSt_mammal_mj"):  # ZsatMajority

    # To allow overwriting outputs change overwriteOutput option to True.
    arcpy.env.overwriteOutput = False

    # Check out any necessary licenses.
    arcpy.CheckOutExtension("spatial")
    arcpy.CheckOutExtension("ImageExt")
    arcpy.CheckOutExtension("ImageAnalyst")


    # Process: Zonal Statistics as Table (Zonal Statistics as Table) (sa)
    arcpy.sa.ZonalStatisticsAsTable(in_zone_data=geometry, zone_field="OBJECTID", in_value_raster=crf_name, out_table=output_table, ignore_nodata="DATA", statistics_type="MAJORITY", process_as_multidimensional="CURRENT_SLICE", percentile_values=[90])
    .save(Zonal_Statistics_as_Table)


if __name__ == '__main__':
    # Global Environment settings
    with arcpy.EnvManager(scratchWorkspace=r"C:\Users\Viz1\Documents\ArcGIS\Projects\SuperSample\SuperSample.gdb", workspace=r"C:\Users\Viz1\Documents\ArcGIS\Projects\SuperSample\SuperSample.gdb"):
        ZsatMajority(*argv[1:])
