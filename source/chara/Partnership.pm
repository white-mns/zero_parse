#===================================================================
#        姉妹提携取得パッケージ
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
package Partnership;

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
                "partner_e_no",
    ];

    $self->{Datas}{Data}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{Data}->SetOutputName( "./output/chara/partnership_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
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
    my $charalist_table_node = shift;
    
    $self->{ENo} = $e_no;

    $self->GetPartnershipData($h3_nodes, $charalist_table_node);
    
    return;
}

#-----------------------------------#
#    姉妹提携データ取得
#------------------------------------
#    引数｜名前データノード
#-----------------------------------#
sub GetPartnershipData{
    my $self  = shift;
    my $h3_nodes  = shift;
    my $charalist_table_node = shift;
    my $partnership = 0;

    if (!$charalist_table_node) {return;}

    foreach my $h3_node (@$h3_nodes) {
        if ($h3_node->as_text =~ /◆姉妹提携/) {
            if ($h3_node->right->as_text =~ /(.+?)とバディを結成した!!/) {
                $partnership = $1;
                $partnership =~ s/\s//g;
            }
            last;
        }
    }

    my $a_nodes = &GetNode::GetNode_Tag("a", \$charalist_table_node);
    
    if ($partnership =~ /^0$/) {return;}

    foreach my $a_node (@$a_nodes) {
        my $link_text = $a_node->as_text;
        $link_text =~ s/\s//g;
        $link_text =~ s/ID\-\d+　//g;

        if ($link_text ne $partnership) {next;}
        
        my $link_href = $a_node->attr("href");
        if ($link_href !~ /c(\d{4})\.html/) {next;}

        if ($1 == $self->{ENo}) {next;}

        $partnership = $1+0;

        last;
    }

    my @datas=($self->{ResultNo}, $self->{GenerateNo}, $self->{ENo}, $partnership);
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
