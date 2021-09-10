# -*- coding: utf-8 -*-
"""
Generated by ArcGIS ModelBuilder on : 2021-09-10 15:48:52
"""
import arcpy
from sys import argv
import arcpy
import numpy as np
def getPresentSpecies(table):
    arr = arcpy.da.TableToNumPyArray(table,["SliceNumber","presence"])
    out_arr = arr[arr["presence"]>0]
    arr_lit = out_arr["SliceNumber"].tolist()
    arr_int = map(int, arr_lit)
    res = ', '.join(map(str, arr_int))  
    out = f"SliceNumber IN ({res})"
    return out
import arcpy
import numpy
def getAreaRaster(rst):
    arr = arcpy.da.TableToNumPyArray(rst, "COUNT")
    a,= arr.tolist()
    res = a[0]
    return res

def sampleUniqueSelectCalculate(crf_name="mammals_for_greta_Subset_Subset_galcia.crf", geometry="unique_square", unique_id_field="unique", output_table="C:\\Users\\Viz1\\Documents\\ArcGIS\\Projects\\SuperSample\\SuperSample.gdb\\Sample_mammals_gal6_TableSel"):  # sampleUniqueSelectCalculate

    # To allow overwriting outputs change overwriteOutput option to True.
    arcpy.env.overwriteOutput = False

    # Check out any necessary licenses.
    arcpy.CheckOutExtension("spatial")
    arcpy.CheckOutExtension("ImageExt")
    arcpy.CheckOutExtension("ImageAnalyst")


    # Process: Sample (Sample) (sa)
    table_in = "C:\\Users\\Viz1\\Documents\\ArcGIS\\Projects\\SuperSample\\SuperSample.gdb\\Sample_mammals_gal6"
    arcpy.sa.Sample(in_rasters=[crf_name], in_location_data=geometry, out_table=table_in, resampling_type="NEAREST", unique_id_field=unique_id_field, process_as_multidimensional="ALL_SLICES", acquisition_definition=[], statistics_type="SUM", percentile_value=None, buffer_distance="", layout="ROW_WISE", generate_feature_class="TABLE")

    # Process: Calculate SQL expression (Calculate Value) ()
    if table_in:
        output_value = getPresentSpecies(r"table_in")

    # Process: Table Select (Table Select) (analysis)
    select_table = "C:\\Users\\Viz1\\Documents\\ArcGIS\\Projects\\SuperSample\\SuperSample.gdb\\Sample_mammals_gal6_TableSel"
    if table_in:
        arcpy.analysis.TableSelect(in_table=table_in, out_table=select_table, where_clause=output_value)

    # Process: Polygon to Raster (Polygon to Raster) (conversion)
    custom_raster = "C:\\Users\\Viz1\\Documents\\ArcGIS\\Projects\\SuperSample\\SuperSample.gdb\\unique_square_PolygonToRaster"
    arcpy.conversion.PolygonToRaster(in_features=geometry, value_field="OBJECTID", out_rasterdataset=custom_raster, cell_assignment="CELL_CENTER", priority_field="NONE", cellsize="C:\\Users\\Viz1\\Documents\\ArcGIS\\Projects\\mammal_data_cube\\mammals_for_greta_Subset.crf")

    # Process: Calculate Value of Area (Calculate Value) ()
    if custom_raster:
        area_value = getAreaRaster(r"custom_raster")

    # Process: Calculate Field (Calculate Field) (management)
    if area_value and custom_raster and table_in:
        output_table = arcpy.management.CalculateField(in_table=select_table, field="percentage_presence", expression=f"round((!presence!/{area_value})*100,2)", expression_type="PYTHON3", code_block="", field_type="TEXT")[0]

if __name__ == '__main__':
    # Global Environment settings
    with arcpy.EnvManager(scratchWorkspace=r"C:\Users\Viz1\Documents\ArcGIS\Projects\SuperSample\SuperSample.gdb", workspace=r"C:\Users\Viz1\Documents\ArcGIS\Projects\SuperSample\SuperSample.gdb"):
        sampleUniqueSelectCalculate(*argv[1:])