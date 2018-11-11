#===================================================================
#        精算結果取得パッケージ
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
package Reward;

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
                "battle_income",
                "add_income",
                "attack",
                "support",
                "defense",
                "defeat",
                "selling",
                "sub_quest",
                "enemy_caution",
                "colosseum_win",
                "fight_money",
                "total_income",
                "ammunition_cost",
                "preparation_deduction",
                "preparation_cost",
                "union_cost",
                "prize",
                "union_interest",
                "parts_sell",
    ];

    $self->{Datas}{Data}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{Data}->SetOutputName( "./output/chara/reward_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
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
    my $reward_node = shift;
    
    $self->{ENo} = $e_no;

    $self->GetRewardData($reward_node);
    
    return;
}

#-----------------------------------#
#    名前データ取得
#------------------------------------
#    引数｜名前データノード
#-----------------------------------#
sub GetRewardData{
    my $self  = shift;
    my $reward_node  = shift;
    my ($battle_income, $add_income, $attack, $support, $defense, $defeat, $selling, $sub_quest, $enemy_caution, $colosseum_win, $fight_money, $total_income, $ammunition_cost, $preparation_deduction, $preparation_cost, $union_cost, $prize, $union_interest, $parts_sell) = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

    my @reward_children = $reward_node->content_list;

    for (my $i=0;$i < scalar(@reward_children);$i++) {
        my $reward_child = $reward_children[$i];

        if ($reward_child =~ /戦闘収入/) {
            $battle_income = $reward_children[$i+1]->as_text;

        } elsif ($reward_child =~ /追加収入/) {
            $add_income = $reward_children[$i+1]->as_text;

        } elsif ($reward_child =~ /攻撃戦果補正/) {
            $attack = $self->ExtractCompensationValue($reward_children[$i+1]->as_text);

        } elsif ($reward_child =~ /支援戦果補正/) {
            $support = $self->ExtractCompensationValue($reward_children[$i+1]->as_text);

        } elsif ($reward_child =~ /防衛戦果補正/) {
            $defense = $self->ExtractCompensationValue($reward_children[$i+1]->as_text);

        } elsif ($reward_child =~ /撃墜数補正/) {
            $defeat = $self->ExtractCompensationValue($reward_children[$i+1]->as_text);

        } elsif ($reward_child =~ /販売数補正/) {
            $selling = $self->ExtractCompensationValue($reward_children[$i+1]->as_text);

        } elsif ($reward_child =~ /サブクエスト/) {
            $sub_quest = $self->ExtractCompensationValue($reward_children[$i+1]->as_text);

        } elsif ($reward_child =~ /コロッセオ勝利補正/) {
            $colosseum_win = $self->ExtractCompensationValue($reward_children[$i+1]->as_text);

        } elsif ($reward_child =~ /ファイトマネー補正/) {
            $fight_money = $self->ExtractCompensationValue($reward_children[$i+1]->as_text);

        } elsif ($reward_child =~ /敵警戒値補正/) {
            $enemy_caution = $self->ExtractCompensationValue($reward_children[$i+1]->as_text);

        } elsif ($reward_child =~ /合計現金収入/) {
            $total_income = $reward_children[$i+1]->as_text;

        } elsif ($reward_child =~ /弾薬費請求/) {
            $ammunition_cost = $reward_children[$i+1]->as_text;

        } elsif ($reward_child =~ /整備控除修正額/) {
            $preparation_deduction = $reward_children[$i+1]->as_text;

        } elsif ($reward_child =~ /整備請求額/) {
            $preparation_cost = $reward_children[$i+1]->as_text;
            
        } elsif ($reward_child =~ /ユニオン費/) {
            $union_cost = $reward_children[$i+1]->as_text;
            
        } elsif ($reward_child =~ /賞金/) {
            $prize = $reward_children[$i+1]->as_text;
            
        } elsif ($reward_child =~ /ユニオン利子/) {
            $union_interest = $reward_children[$i+1]->as_text;
            
        } elsif ($reward_child =~ /パーツ販売数/) {
            my $text = $reward_children[$i+1]->as_text;
            $text =~ s/個//g;
            $parts_sell = $text;
        }
    }

    my @datas=($self->{ResultNo}, $self->{GenerateNo}, $self->{ENo}, $battle_income, $add_income, $attack, $support, $defense, $defeat, $selling, $sub_quest, $enemy_caution, $colosseum_win, $fight_money, $total_income, $ammunition_cost, $preparation_deduction, $preparation_cost, $union_cost, $prize, $union_interest, $parts_sell);
    $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, @datas));

    return;
}

#-----------------------------------#
#    補正値取得
#------------------------------------
#    引数｜補正値テキスト
#-----------------------------------#
sub ExtractCompensationValue{
    my $self = shift;
    my $text  = shift;

    $text =~ s/(％$|％\(MAX\)$)//g;

    return $text;
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
