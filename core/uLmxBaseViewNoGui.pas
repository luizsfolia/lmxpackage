unit uLmxBaseViewNoGui;

interface

uses
  Classes;

type

  TLmxBaseView = class(TComponent);
  TLmxBaseConsultaView = class(TComponent);
  TLmxBaseCadastroView = class(TComponent);
  TLmxBaseConsultaViewClass = class of TLmxBaseConsultaView;
  TLmxBaseViewClass = class of TLmxBaseView;
  TLmxBaseCadastroViewClass = class of TLmxBaseCadastroView;
  TLmxBaseDataBaseView = class(TComponent);
  TLmxBaseDataBaseViewClass = class of TLmxBaseDataBaseView;


implementation

end.
