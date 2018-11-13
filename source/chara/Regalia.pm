#===================================================================
#        レガリア取得パッケージ
#-------------------------------------------------------------------
#            (C) 2018 @white_mns
#===================================================================


# パッケージの使用宣言    ---------------#   
use strict;
use warnings;
require "./source/lib/Store_Data.pm";
require "./source/lib/Store_HashData.pm";
use ConstData;        #定数呼び出し
use source::lib::GetNode;


#------------------------------------------------------------------#
#    パッケージの定義
#------------------------------------------------------------------#     
package Regalia;

#-----------------------------------#
#    コンストラクタ
#-----------------------------------#
sub new {
  my $class = shift;
  
  bless {
        Datas => {},
  }, $class;
}

#-----------------------------------#
#    初期化
#-----------------------------------#
sub Init(){
    my $self = shift;
    ($self->{ResultNo}, $self->{GenerateNo}, $self->{CommonDatas}) = @_;
    
    #初期化
    $self->{Datas}{Data}  = StoreData->new();
    my $header_list = "";
   
    $header_list = [
                "result_no",
                "generate_no",
                "e_no",
                "regalia_id",
    ];

    $self->{Datas}{Data}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{Data}->SetOutputName( "./output/chara/regalia_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜e_no,名前データノード
#-----------------------------------#
sub GetData{
    my $self = shift;
    my $e_no = shift;
    my $h3_nodes = shift;
    
    $self->{ENo} = $e_no;

    $self->GetRegaliaData($h3_nodes);
    
    return;
}

#-----------------------------------#
#    レガリアデータ取得
#------------------------------------
#    引数｜名前データノード
#-----------------------------------#
sub GetRegaliaData{
    my $self  = shift;
    my $h3_nodes  = shift;
    my $regalia = 0;

    foreach my $h3_node (@$h3_nodes) {
        if ($h3_node->as_text =~ /◆レガリア決定/) {
            if ($h3_node->right->as_text =~ /(.+?) に決定!!/) {
                $regalia = $self->{CommonDatas}{ProperName}->GetOrAddId($1);
            }
            last;
        }
    }

    my @datas=($self->{ResultNo}, $self->{GenerateNo}, $self->{ENo}, $regalia);
    $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, @datas));

    return;
}

#-----------------------------------#
#    出力
#------------------------------------
#    引数｜ファイルアドレス
#-----------------------------------#
sub Output(){
    my $self = shift;
    
    foreach my $object( values %{ $self->{Datas} } ) {
        $object->Output();
    }
    return;
}
1;
