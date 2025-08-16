CLASS zcl_qm_cert_scr DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_QM_CERT_SCR IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    IF io_request->is_data_requested( ).

      DATA: lt_response    TYPE TABLE OF ZCDS_QM_CERT_NEW,
            ls_response    LIKE LINE OF lt_response,
            lt_responseout LIKE lt_response,
            ls_responseout LIKE LINE OF lt_responseout.

      DATA(lv_top)   =   io_request->get_paging( )->get_page_size( ).
      DATA(lv_skip)  =   io_request->get_paging( )->get_offset( ).
      DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0 ELSE lv_top ).

*      DATA(lt_clause)  = io_request->get_filter( )->get_as_ranges( ).
*      DATA(lt_parameters)  = io_request->get_parameters( ).
*      DATA(lt_fileds)  = io_request->get_requested_elements( ).
*      DATA(lt_sort)  = io_request->get_sort_elements( ).
*
*      TRY.
*          DATA(lt_Filter_cond) = io_request->get_filter( )->get_as_ranges( ).
*        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
*      ENDTRY.

 TRY.
          DATA(lt_parameters)  = io_request->get_parameters( ).
          DATA(lt_fileds)  = io_request->get_requested_elements( ).
          DATA(lt_sort)  = io_request->get_sort_elements( ).


          DATA(lt_Filter_cond) = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
          CLEAR lx_no_sel_option.
      ENDTRY.


      LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
        IF ls_filter_cond-name = 'INSPECTIONLOT'.
          DATA(lt_inspectionlot) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'BATCH'.
          DATA(lt_batch) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'MATERIAL'.
          DATA(lt_mat) = ls_filter_cond-range[].
        ENDIF.
      ENDLOOP.


      SELECT
      a~InspectionLot,
      a~batch,
      a~material
      FROM i_inspectionlot WITH PRIVILEGED ACCESS AS a
      WHERE a~InspectionLot IN @lt_inspectionlot
      AND a~Batch IN @lt_batch
      AND a~Material IN @lt_mat
      INTO TABLE @DATA(it_item).

      loop at it_item INTO DATA(wa).
      ls_response-InspectionLot = wa-InspectionLot.
      ls_response-Batch = wa-Batch .
      ls_response-Material = wa-Material.
      APPEND ls_response TO lt_response.
      clear wa.
      clear ls_response.

      ENDLOOP.




      lv_max_rows = lv_skip + lv_top.
      IF lv_skip > 0.
        lv_skip = lv_skip + 1.
      ENDIF.

      CLEAR lt_responseout.
      LOOP AT lt_response ASSIGNING FIELD-SYMBOL(<lfs_out_line_item>) FROM lv_skip TO lv_max_rows.
        ls_responseout = <lfs_out_line_item>.
        APPEND ls_responseout TO lt_responseout.
      ENDLOOP.

      io_response->set_total_number_of_records( lines( lt_response ) ).
      io_response->set_data( lt_responseout ).

    ENDIF.
  ENDMETHOD.
ENDCLASS.
