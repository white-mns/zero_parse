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
                "reword_type",
                "value",
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

    my @reward_children = $reward_node->content_list;

    for (my $i=0;$i < scalar(@reward_children);$i++) {
        my ($reward_type, $value) = (0, 0);
        my $reward_child = $reward_children[$i];
        if ($reward_children[$i+1] && $reward_children[$i+1] =~ /HASH/) {$value = $reward_children[$i+1]->as_text};

        if ($reward_child =~ /戦利売上高/) {
            $reward_type =  $self->{CommonDatas}{ProperName}->GetOrAddId("戦利売上高");

        } elsif ($reward_child =~ /攻撃戦果収入/) {
            $reward_type =  $self->{CommonDatas}{ProperName}->GetOrAddId("攻撃戦果");

        } elsif ($reward_child =~ /支援戦果収入/) {
            $reward_type =  $self->{CommonDatas}{ProperName}->GetOrAddId("支援戦果");

        } elsif ($reward_child =~ /防衛戦果収入/) {
            $reward_type =  $self->{CommonDatas}{ProperName}->GetOrAddId("防衛戦果");

        } elsif ($reward_child =~ /捕虜交換/) {
            $reward_type =  $self->{CommonDatas}{ProperName}->GetOrAddId("捕虜交換");

        } elsif ($reward_child =~ /合計現金収入/) {
            $reward_type =  $self->{CommonDatas}{ProperName}->GetOrAddId("合計現金収入");

        } elsif ($reward_child =~ /【！】収入/) {
            $reward_type =  $self->{CommonDatas}{ProperName}->GetOrAddId("収入");
            if ($value =~ /(\d)money/) {
                $value = $1;
            }

        } elsif ($reward_child =~ /【！】経費/) {
            $reward_type =  $self->{CommonDatas}{ProperName}->GetOrAddId("経費");
            if ($value =~ /(\d)money/) {
                $value = $1;
            }
        }

        if ($reward_type) {
            $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{GenerateNo}, $self->{ENo}, $reward_type, $value) ));
        }
    }


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
