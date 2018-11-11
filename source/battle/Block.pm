#===================================================================
#        ブロック所属取得パッケージ
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
package Block;

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

    $self->{CommonDatas}{NickName} = {};
    
    #初期化
    $self->{Datas}{Data}  = StoreData->new();
    my $header_list = "";
   
    $header_list = [
                "result_no",
                "generate_no",
                "block_no",
                "e_no",
    ];

    $self->{Datas}{Data}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{Data}->SetOutputName( "./output/battle/block_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜e_no,名前データノード
#-----------------------------------#
sub GetData{
    my $self = shift;
    my $battle_no  = shift;
    my $lifelist_table_node = shift;
    
    $self->{BattleNo} = $battle_no;

    $self->GetBlockData($lifelist_table_node);
    
    return;
}
#-----------------------------------#
#    多重購入データ取得
#------------------------------------
#    引数｜名前データノード
#-----------------------------------#
sub GetBlockData{
    my $self  = shift;
    my $lifelist_table_node  = shift;

    my $a_nodes = &GetNode::GetNode_Tag("a", \$lifelist_table_node);

    foreach my $a_node (@$a_nodes) {
        my $link_text = $a_node->attr("href");

        if ($link_text !~ /c(\d{4})\.html/) { next;}
        my $e_no = $1+0;
        my @datas=($self->{ResultNo}, $self->{GenerateNo},  $self->{BattleNo} + 1, $e_no);
        $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, @datas));
    }

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
