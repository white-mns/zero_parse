#===================================================================
#        機体データ取得パッケージ
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
package Spec;

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
    $self->{Datas}{Spec}                 = StoreData->new();
    $self->{Datas}{ConditionAllTextData} = StoreData->new();

    my $header_list = "";
   
    $header_list = [
                "result_no",
                "generate_no",
                "e_no",
                "invation",
                "encount",
                "technic",
                "goodwill",
                "intelligence",
                "illegality",
    ];
    $self->{Datas}{Spec}->Init($header_list);

    $header_list = [
                "result_no",
                "generate_no",
                "e_no",
                "condition_text",
    ];

    $self->{Datas}{ConditionAllTextData}->Init($header_list);
    #出力ファイル設定
    $self->{Datas}{Spec}->SetOutputName                ( "./output/chara/spec_"               . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    $self->{Datas}{ConditionAllTextData}->SetOutputName( "./output/chara/condition_all_text_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜e_no,城塞データノード
#-----------------------------------#
sub GetData{
    my $self           = shift;
    my $e_no           = shift;
    my $spec_data_node = shift;
    
    $self->{ENo} = $e_no;

    $self->GetSpec($spec_data_node);
    
    return;
}

#-----------------------------------#
#    城塞データ取得
#------------------------------------
#    引数｜城塞データノード
#-----------------------------------#
sub GetSpec{
    my $self           = shift;
    my $spec_data_node = shift;
    my ($invation, $encount, $technic, $goodwill, $intelligence, $illegality) = (0, 0, 0, 0, 0, 0);

    my $th_nodes = &GetNode::GetNode_Tag("th", \$spec_data_node);

    foreach my $th_node (@$th_nodes) {
        if ($th_node->as_text eq "進行速度") {
            $invation = $th_node->right->as_text;

        } elsif ($th_node->as_text eq "エンカウント") {
            $encount = $th_node->right->as_text;

        } elsif ($th_node->as_text eq "機巧技術") {
            $technic = $th_node->right->as_text;

        } elsif ($th_node->as_text eq "好感度") {
            $goodwill = $th_node->right->as_text;

        } elsif ($th_node->as_text eq "知性") {
            $intelligence = $th_node->right->as_text;

        } elsif ($th_node->as_text eq "違法性") {
            $illegality = $th_node->right->as_text;

        }
    }

    $self->{Datas}{Spec}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{GenerateNo}, $self->{ENo}, $invation, $encount, $technic, $goodwill, $intelligence, $illegality) ));

    return;
}

#-----------------------------------#
#    機体状況データ取得
#------------------------------------
#    引数｜機体状況ノード
#-----------------------------------#
sub GetConditionData{
    my $self           = shift;
    my $condition_node = shift;

    my ($condition, $condition_text) = (0, "");

    foreach my $child ($condition_node->content_list) {
        my $text = ($child =~ /HASH/) ? $child->as_text : $child;
        
        if (!($text && $text ne " ")) { next;}
        if ($text =~ /付加発動/)     { last;}
        if ($text =~ /(.+)…(.+)/) {
            $condition = $self->{CommonDatas}{ProperName}->GetOrAddId($1);

        } else {
            $condition = $self->{CommonDatas}{ProperName}->GetOrAddId($text);
        }
        $condition_text .= ($text && $text ne " ") ? "$text," : "";
    }

    chop($condition_text);
    my @datas=($self->{ResultNo}, $self->{GenerateNo}, $self->{ENo}, $condition_text);
    $self->{Datas}{ConditionAllTextData}->AddData(join(ConstData::SPLIT, @datas));

    return;
}

#----------------------------------#
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
