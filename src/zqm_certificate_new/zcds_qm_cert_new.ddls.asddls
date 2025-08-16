
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'cds view for QM CERTIFICATION'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.query.implementedBy: 'ABAP:ZCL_QM_CERT_SCR'
@UI.headerInfo: {typeName: 'QM Certification'}
define root view entity ZCDS_QM_CERT_NEW as select from I_InspectionLot

{
     

     @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:1 }]
      @UI.lineItem   : [{ position:1, label:'inspection lot number' }]
  key InspectionLot,


      @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:2 }]
      @UI.lineItem   : [{ position:2, label:'batch' }]
      Batch,
      
      
      @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:3 }]
      @UI.lineItem   : [{ position:3, label:'material' }]
      Material
}
