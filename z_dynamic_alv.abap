*--------------------------------------------------------------------*
* Utku Y. ABAP Dynamic ALV Sample
*--------------------------------------------------------------------*
* Description:
*   Sample - Dynamic ALV
*--------------------------------------------------------------------*
* Change log:
*  10.01.2017 13:40:50 - BTC-UYEGEN
*--------------------------------------------------------------------*

REPORT z_dynamic_alv.

CONSTANTS: lc_prefix TYPE c LENGTH 5 VALUE 'FIELD'.
DATA: lv_max_field  TYPE i,
      ls_layout     TYPE slis_layout_alv,
      lt_fieldcat_t TYPE lvc_t_fcat,
      ls_fieldcat_t LIKE LINE OF lt_fieldcat_t,
      lt_fieldcat   TYPE slis_t_fieldcat_alv,
      ls_fieldcat   LIKE LINE OF lt_fieldcat,
      lv_number     TYPE c LENGTH 3,
      lv_fieldname  TYPE slis_fieldname.
DATA: lr_data TYPE REF TO data,
      lr_line TYPE REF TO data.
FIELD-SYMBOLS: <ft_data>        TYPE STANDARD TABLE,
               <fs_data>        TYPE any,
               <fv_field_value> TYPE any.

WHILE lv_max_field IS INITIAL.
  CALL FUNCTION 'GENERAL_GET_RANDOM_INT'
    EXPORTING
      range  = 20
    IMPORTING
      random = lv_max_field.
ENDWHILE.

ls_layout-zebra = 'X'.

DO lv_max_field TIMES.
  lv_number = sy-index.
  ls_fieldcat-col_pos = sy-index.
  CONCATENATE lc_prefix lv_number INTO ls_fieldcat-fieldname.
  CONDENSE ls_fieldcat-fieldname NO-GAPS.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m = ls_fieldcat-seltext_l = ls_fieldcat-fieldname.
  APPEND ls_fieldcat TO lt_fieldcat.

  MOVE-CORRESPONDING ls_fieldcat TO ls_fieldcat_t.
  APPEND ls_fieldcat_t TO lt_fieldcat_t.
ENDDO.

CALL METHOD cl_alv_table_create=>create_dynamic_table
  EXPORTING
    it_fieldcatalog           = lt_fieldcat_t
  IMPORTING
    ep_table                  = lr_data
  EXCEPTIONS
    generate_subpool_dir_full = 1
    OTHERS                    = 2.
ASSIGN lr_data->*  TO <ft_data>.

DO lines( lt_fieldcat_t ) TIMES.
  CREATE DATA lr_line LIKE LINE OF <ft_data>.
  ASSIGN lr_line->* TO <fs_data>.
  DO sy-index TIMES.
    lv_number = sy-index.
    CONCATENATE lc_prefix lv_number INTO lv_fieldname.
    CONDENSE lv_fieldname NO-GAPS.
    ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_data> TO <fv_field_value>.
    <fv_field_value> = lv_number.
  ENDDO.
  APPEND <fs_data> TO <ft_data>.
ENDDO.

CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
  EXPORTING
    i_callback_program = sy-repid
    is_layout          = ls_layout
    it_fieldcat        = lt_fieldcat
  TABLES
    t_outtab           = <ft_data>
  EXCEPTIONS
    program_error      = 1
    OTHERS             = 2.
