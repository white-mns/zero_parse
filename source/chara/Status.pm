#===================================================================
#        ステータス取得パッケージ
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
package Status;

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
                "acc_reward",
                "rp",
                "gunshot",
                "struggle",
                "reaction",
                "control",
                "preparation",
                "fitly",
                "funds",
                "exp",
    ];

    $self->{Datas}{Data}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{Data}->SetOutputName( "./output/chara/status_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜e_no,ステータスデータノード
#-----------------------------------#
sub GetData{
    my $self         = shift;
    my $e_no         = shift;
    my $status_nodes = shift;
    
    $self->{ENo} = $e_no;

    $self->GetStatusData($status_nodes);
    
    return;
}
#-----------------------------------#
#    ステータスデータ取得
#------------------------------------
#    引数｜ステータスデータノード
#-----------------------------------#
sub GetStatusData{
    my $self         = shift;
    my $status_node  = shift;


    my ($acc_reward, $rp, $gunshot, $struggle, $reaction, $control, $preparation, $fitly, $funds, $exp) = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    my $th_nodes = &GetNode::GetNode_Tag("th", \$status_node);

    foreach my $th_node (@$th_nodes) {
        if ($th_node->as_text eq "累積報酬") {
            $acc_reward = $th_node->right->as_text;

        } elsif ($th_node->as_text eq "RP") {
            $rp = $th_node->right->as_text;

        } elsif ($th_node->as_text eq "射撃") {
            $gunshot = $th_node->right->as_text;

        } elsif ($th_node->as_text eq "格闘") {
            $struggle = $th_node->right->as_text;

        } elsif ($th_node->as_text eq "反応") {
            $reaction = $th_node->right->as_text;

        } elsif ($th_node->as_text eq "制御") {
            $control = $th_node->right->as_text;

        } elsif ($th_node->as_text eq "整備") {
            $preparation = $th_node->right->as_text;

        } elsif ($th_node->as_text eq "適性") {
            $fitly = $th_node->right->as_text;

        } elsif ($th_node->as_text eq "所持資金") {
            $funds = $th_node->right->as_text;

        } elsif ($th_node->as_text eq "経験値") {
            $exp = $th_node->right->as_text;

        }
    }
    my @datas=($self->{ResultNo}, $self->{GenerateNo}, $self->{ENo}, $acc_reward, $rp, $gunshot, $struggle, $reaction, $control, $preparation, $fitly, $funds, $exp);
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
