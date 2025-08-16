 CLASS zqm_certificate_drv_new DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
*    INTERFACES if_oo_adt_classrun .
    CLASS-DATA : access_token TYPE string .
    CLASS-DATA : xml_file TYPE string .
    TYPES :
      BEGIN OF struct,
        xdp_template TYPE string,
        xml_data     TYPE string,
        form_type    TYPE string,
        form_locale  TYPE string,
        tagged_pdf   TYPE string,
        embed_font   TYPE string,
      END OF struct."


    CLASS-METHODS :
      create_client
        IMPORTING url           TYPE string
        RETURNING VALUE(result) TYPE REF TO if_web_http_client
        RAISING   cx_static_check ,

      read_posts
        IMPORTING po_num           TYPE string
        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .
  PROTECTED SECTION.

  PRIVATE SECTION.
    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'zqm_certificate/zqm_certificate'."'zpo/zpo_v2'."
*    CONSTANTS lc_template_name TYPE 'HDFC_CHECK/HDFC_MULTI_FINAL_CHECK'.

ENDCLASS.



CLASS ZQM_CERTIFICATE_DRV_NEW IMPLEMENTATION.


METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

  ENDMETHOD .


   METHOD read_posts. "if_oo_adt_classrun~main.

 .

      SELECT SINGLE FROM i_inspectionlot AS a
      LEFT JOIN i_supplier AS b ON a~supplier = b~supplier
      LEFT JOIN i_inspectionresultvalue AS c ON a~inspectionlot = c~inspectionlot
      FIELDS
        a~inspectionlotobjecttext, a~material, a~inspectionlot, a~materialdocument, a~inspectionlotquantity,
        a~insplotcreatedonlocaldate, a~insplotqtytoblocked, a~inspectionlotsamplequantity, a~companycode,
        b~suppliername, c~inspector
      WHERE a~inspectionlot = @po_num
      INTO @DATA(wa_head).

    " Fetch item data
    SELECT FROM i_inspectionlot AS a
      LEFT JOIN i_inspectioncharacteristic AS b ON a~inspectionlot = b~inspectionlot
      LEFT JOIN i_inspectionresultvalue AS c ON b~inspectionlot = c~inspectionlot AND b~inspectioncharacteristic = c~inspectioncharacteristic
      LEFT JOIN I_INSPECTIONCODETEXT AS D ON D~INSPECTIONCODEGROUP = C~CharacteristicAttributeCodeGrp and d~INSPECTIONCODE = c~CHARACTERISTICATTRIBUTECODE
      FIELDS
        b~inspectioncharacteristic, b~inspectioncharacteristictext, b~inspspecupperlimit, b~inspspeclowerlimit,
        b~inspectionspecificationunit, b~inspectionmethod, c~inspectionresultoriginalvalue,
        c~inspectionresultmeasuredvalue, c~CharacteristicAttributeCode , d~InspectionCodeText
      WHERE a~inspectionlot = @po_num
      INTO TABLE @DATA(it_line).


* OUT->WRITE( it_line ).
    " Initialize XML structure
    DATA(lv_xml) = |<Form>| &&
                   |<Inspection>| &&
                   |<NameOfMat>{ wa_head-inspectionlotobjecttext }</NameOfMat>| &&
                   |<MaterialCode>{ wa_head-material }</MaterialCode>| &&
                   |<INSPECTIONLotNumber>{ wa_head-inspectionlot }</INSPECTIONLotNumber>| &&
                   |<GRNnumber>{ wa_head-materialdocument }</GRNnumber>| &&
                   |<DateOfSampling>{ wa_head-insplotcreatedonlocaldate }</DateOfSampling>| &&
                   |<RecevingQty>{ wa_head-inspectionlotquantity }</RecevingQty>| &&
                   |<RejectedQty>{ wa_head-insplotqtytoblocked }</RejectedQty>| &&
                   |<SampleSize>{ wa_head-inspectionlotsamplequantity }</SampleSize>| &&
                   |<CompanyCode>{ wa_head-companycode }</CompanyCode>| &&
                   |<SupplierName>{ wa_head-suppliername }</SupplierName>| &&
                   |<NameOfInspector>{ wa_head-inspector }</NameOfInspector>| &&
                   |</Inspection>| &&
                   |<item>|.

    " Initialize counter
    DATA(num) = 0.

    LOOP AT it_line INTO DATA(wa_line).
      num = num + 1.

      " Format `InspectionResultMeasuredValue`
      DATA lv_formatted_value TYPE string.
      CLEAR lv_formatted_value.

      IF wa_line-inspectionresultmeasuredvalue = 0.
        lv_formatted_value = wa_line-InspectionCodeText.  " Preserve leading zeros (e.g., "01", "02")
      ELSE.
        lv_formatted_value = |{ wa_line-inspectionresultmeasuredvalue WIDTH = 10 ALIGN = LEFT }|.
        CONDENSE lv_formatted_value.
      ENDIF.

      " Append formatted data to XML
      DATA(lv_xml2) =
        |<tableDataRows>| &&
        |<siNo>{ num }</siNo>| &&
        |<TestParameter>{ wa_line-inspectioncharacteristictext }</TestParameter>| &&
        |<LowerSpecification>{ wa_line-inspspeclowerlimit }</LowerSpecification>| &&
        |<UpperSpecification>{ wa_line-inspspecupperlimit }</UpperSpecification>| &&
        |<Result>{ wa_line-inspectionspecificationunit }</Result>| &&
        |<InspectionMethod>{ lv_formatted_value }</InspectionMethod>| &&
        |</tableDataRows>|.

      CONCATENATE lv_xml lv_xml2 INTO lv_xml.
    ENDLOOP.

    " Close XML structure
    CONCATENATE lv_xml '</item>' '</Form>' INTO lv_xml.

    " Replace special characters
    REPLACE ALL OCCURRENCES OF '&' IN lv_xml WITH 'and'.
    REPLACE ALL OCCURRENCES OF '<=' IN lv_xml WITH 'let'.
    REPLACE ALL OCCURRENCES OF '>=' IN lv_xml WITH 'get'.

    " Output final XML
*   out->write( lv_xml ).




 CALL METHOD zcl_ads_print=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).
  ENDMETHOD.
ENDCLASS.
