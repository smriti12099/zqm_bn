@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS view for inspection lot'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
@UI.headerInfo: {typeName: 'QM Certification', typeNamePlural: 'QM Certificate' }
define root view entity zi_inspection_lot_cds
  as select from I_InspectionLot
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
      Material,
      
      @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:4 }]
      @UI.lineItem   : [{ position:3, label:'Plant' }]
      Plant
}
