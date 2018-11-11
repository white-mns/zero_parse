#===================================================================
#        戦闘ページ解析パッケージ
#-------------------------------------------------------------------
#            (C) 2018 @white_mns
#===================================================================


# パッケージの使用宣言    ---------------#
use strict;
use warnings;

use ConstData;
use HTML::TreeBuilder;
use source::lib::GetNode;


require "./source/lib/IO.pm";
require "./source/lib/time.pm";
require "./source/lib/NumCode.pm";

require "./source/battle/Block.pm";
require "./source/battle/Transition.pm";

use ConstData;        #定数呼び出し

#------------------------------------------------------------------#
#    パッケージの定義
#------------------------------------------------------------------#
package Battle;

#-----------------------------------#
#    コンストラクタ
#-----------------------------------#
sub new {
  my $class = shift;

  bless {
    Datas         => {},
    DataHandlers  => {},
    Methods       => {},
  }, $class;
}

#-----------------------------------#
#    初期化
#-----------------------------------#
sub Init(){
    my $self = shift;
    ($self->{ResultNo}, $self->{GenerateNo}, $self->{CommonDatas}) = @_;
    $self->{ResultNo0} = sprintf("%03d", $self->{ResultNo});

    #インスタンス作成
    if (ConstData::EXE_BATTLE_BLOCK)      { $self->{DataHandlers}{Block}      = Block->new();}
    if (ConstData::EXE_BATTLE_TRANSITION) { $self->{DataHandlers}{Transition} = Transition->new();}

    #初期化処理
    foreach my $object( values %{ $self->{DataHandlers} } ) {
        $object->Init($self->{ResultNo}, $self->{GenerateNo}, $self->{CommonDatas});
    }
    
    return;
}

#-----------------------------------#
#    圧縮結果から詳細データファイルを抽出
#-----------------------------------#
#    
#-----------------------------------#
sub Execute{
    my $self        = shift;

    print "read battle files...\n";

    my $start = 1;
    my $end   = 0;
    my $directory = './data/utf/' . $self->{ResultNo0};
    $directory .= ($self->{GenerateNo} == 0) ? '' :  '_' . $self->{GenerateNo};
    $directory .= '/RESULT';
    if(ConstData::EXE_ALLRESULT){
        #結果全解析
        my @file_list = grep { -f } glob("$directory/battle*.html");
        my $i = 0;
        foreach my $file_adr (@file_list){
            $i++;
            if ($i % 10 == 0) {print $i . "\n"};

            $file_adr =~ /battle(.*?)\.html/;
            my $file_name = $1;
            my $battle_no = $file_name+0;

            $self->ParsePage($directory  . "/battle" . $file_name . ".html", $battle_no);
        }
    }else{
        #指定範囲解析
        $start = ConstData::FLAGMENT_START;
        $end   = ConstData::FLAGMENT_END;
        print "$start to $end\n";

        for (my $i=$start; $i<=$end; $i++) {
            if ($i % 10 == 0) {print $i . "\n"};
            my $i0 = sprintf("%d", $i);
            $self->ParsePage($directory  . "/battle" . $i0 . ".html",$i);
        }
    }

    
    return ;
}
#-----------------------------------#
#       ファイルを解析
#-----------------------------------#
#    引数｜ファイル名
#    　　　ENo
#    　　　FNo
##-----------------------------------#
sub ParsePage{
    my $self        = shift;
    my $file_name   = shift;
    my $battle_no   = shift;

    #結果の読み込み
    my $content = "";
    $content = &IO::FileRead($file_name);

    if(!$content){ return;}

    $content = &NumCode::EncodeEscape($content);
        
    #スクレイピング準備
    my $tree = HTML::TreeBuilder->new;
    $tree->parse($content);

    my $lifelist_table_nodes = &GetNode::GetNode_Tag_Attr("table", "class", "lifelist", \$tree);
    my $h2_nodes             = &GetNode::GetNode_Tag("h2", \$tree);

    # データリスト取得
    if (exists($self->{DataHandlers}{Block}))      {$self->{DataHandlers}{Block}->GetData     ($battle_no, $$lifelist_table_nodes[0])};
    if (exists($self->{DataHandlers}{Transition})) {$self->{DataHandlers}{Transition}->GetData($battle_no, $h2_nodes)};

    $tree = $tree->delete;
}

#-----------------------------------#
#    出力
#-----------------------------------#
#    引数｜ファイルアドレス
#-----------------------------------#
sub Output(){
    my $self = shift;
    foreach my $object( values %{ $self->{Datas} } ) {
        $object->Output();
    }
    foreach my $object( values %{ $self->{DataHandlers} } ) {
        $object->Output();
    }
    return;
}

1;
