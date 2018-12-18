#===================================================================
#        戦闘推移取得パッケージ
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
package Transition;

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

    $self->{TypeName} = {
        "攻撃" => 1,
        "支援" => 2,
        "防衛" => 3,
    };
    
    #初期化
    $self->{Datas}{Data}  = StoreData->new();
    my $header_list = "";
   
    $header_list = [
                "result_no",
                "generate_no",
                "block_no",
                "e_no",
                "turn",
                "act",
                "data_type",
                "value",
    ];

    $self->{Datas}{Data}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{Data}->SetOutputName( "./output/battle/transition_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜e_no,名前データノード
#-----------------------------------#
sub GetData{
    my $self = shift;
    my $battle_no = shift;
    my $h3_nodes  = shift;
    
    $self->{BattleNo} = $battle_no;

    $self->ReadH3Nodes($h3_nodes);
    
    return;
}

#-----------------------------------#
#    h3データ(戦闘機動)別にデータ分解
#------------------------------------
#    引数｜h3ノード
#-----------------------------------#
sub ReadH3Nodes{
    my $self  = shift;
    my $h3_nodes = shift;
    
    foreach my $h3_node (@$h3_nodes) {
        my $turn = 0;
        my $act  = 0;
        my $e_no  = 0;
    
        if ($h3_node->as_text =~ /(午前|午後)(\d+)時(\d+)分 (\d+)番街(\d+)回目の(?:残像の)*(.+)の城状況!!/) {
    
            my $hour = $2;
            my $minute = $3;
            if ($1 eq "午後") {
                $hour += 12;
            }
            $turn = "2019-01-01 $hour:$minute:00";
            $act = $5;
            my $nickname = $6;
            if (exists($self->{CommonDatas}{NickName}{$nickname})) {
                $e_no = $self->{CommonDatas}{NickName}{$nickname};
            }
        }
    
        #if ($e_no == 0) {return;}
    
        $self->ReadActNodes($h3_node, $turn, $act, $e_no);
    }

    return;
}

#-----------------------------------#
#    戦闘機動データ解析
#------------------------------------
#    引数｜h3ノード or INDクラスの最初の子ノード
#-----------------------------------#
sub ReadActNodes{
    my $self  = shift;
    my $start_node = shift;
    my $turn = shift;
    my $act  = shift;
    my $e_no = shift;

    #if ($e_no == 0) {return;}

    foreach my $node ($start_node->right) {
        if ($node =~ /HASH/ && ($node->tag eq "h2" || $node->tag eq "h3")) {last;}

        if ($node =~ /HASH/ && $node->tag eq "div" && $node->attr("class") && $node->attr("class") eq "IND") {
            my @children = $node->content_list;
            if (scalar(@children) && $children[0] =~ /HASH/) {
                $self->ReadActNodes($children[0], $turn, $act, $e_no); # コロッセオ敵側配置の時、再帰で解析
            }
        }

        if ($node =~ /HASH/ && $node->tag eq "span") {
            $self->GetResultTransitionData($node, $turn, $act, $e_no);
        }
    }

    return;
}

#-----------------------------------#
#    spanデータ解析・戦果データなら取得
#------------------------------------
#    引数｜spanノード
#-----------------------------------#
sub GetResultTransitionData{
    my $self = shift;
    my $span_node = shift;
    my $turn = shift;
    my $act  = shift;
    my $e_no = shift;

    if ($span_node->as_text =~ /戦果：攻撃(\d+\.*\d*)％　支援：(\d+\.*\d*)％　防衛：(\d+\.*\d*)％/) {
        $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{GenerateNo},  $self->{BattleNo} + 1, $e_no, $turn, $act, $self->{TypeName}{"攻撃"}, $1)));
        $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{GenerateNo},  $self->{BattleNo} + 1, $e_no, $turn, $act, $self->{TypeName}{"支援"}, $2)));
        $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{GenerateNo},  $self->{BattleNo} + 1, $e_no, $turn, $act, $self->{TypeName}{"防衛"}, $3)));
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
