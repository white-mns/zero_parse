#===================================================================
#        キャラステータス解析パッケージ
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

require "./source/chara/Name.pm";
require "./source/chara/Status.pm";
require "./source/chara/Spec.pm";
require "./source/chara/Reward.pm";
require "./source/chara/BattleSystem.pm";
require "./source/chara/Intention.pm";
require "./source/chara/Partnership.pm";

use ConstData;        #定数呼び出し

#------------------------------------------------------------------#
#    パッケージの定義
#------------------------------------------------------------------#
package Character;

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
sub Init() {
    my $self = shift;
    ($self->{ResultNo}, $self->{GenerateNo}, $self->{CommonDatas}) = @_;
    $self->{ResultNo0} = sprintf ("%03d", $self->{ResultNo});

    #インスタンス作成
    if (ConstData::EXE_CHARA_NAME)          { $self->{DataHandlers}{Name}         = Name->new();}
    if (ConstData::EXE_CHARA_STATUS)        { $self->{DataHandlers}{Status}       = Status->new();}
    if (ConstData::EXE_CHARA_SPEC)          { $self->{DataHandlers}{Spec}         = Spec->new();}
    if (ConstData::EXE_CHARA_REWARD)        { $self->{DataHandlers}{Reward}       = Reward->new();}
    if (ConstData::EXE_CHARA_BATTLE_SYSTEM) { $self->{DataHandlers}{BattleSystem} = BattleSystem->new();}
    if (ConstData::EXE_CHARA_INTENTION)     { $self->{DataHandlers}{Intention}    = Intention->new();}
    if (ConstData::EXE_CHARA_PARTNERSHIP)   { $self->{DataHandlers}{Partnership}  = Partnership->new();}

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

    print "read character files...\n";

    my $start = 1;
    my $end   = 0;
    my $directory = './data/utf/' . $self->{ResultNo0};
    $directory .= ($self->{GenerateNo} == 0) ? '' :  '_' . $self->{GenerateNo};
    $directory .= '/RESULT';
    if (ConstData::EXE_ALLRESULT) {
        #結果全解析
        my @file_list = grep { -f } glob("$directory/c*.html");
        my $i = 0;
        foreach my $file_adr (@file_list) {
            if ($file_adr =~ /catalog/) {next};
            $i++;
            if ($i % 10 == 0) {print $i . "\n"};

            $file_adr =~ /c(.*?)\.html/;
            my $file_name = $1;
            my $e_no = $file_name+0;
            
            $self->ParsePage($directory  . "/c" . $file_name . ".html", $e_no);
        }
    }else{
        #指定範囲解析
        $start = ConstData::FLAGMENT_START;
        $end   = ConstData::FLAGMENT_END;
        print "$start to $end\n";

        for(my $i=$start; $i<=$end; $i++) {
            if ($i % 10 == 0) {print $i . "\n"};
            my $i0 = sprintf ("%04d", $i);
            $self->ParsePage($directory  . "/c" . $i0 . ".html",$i);
        }
    }

    
    return ;
}
#-----------------------------------#
#       ファイルを解析
#-----------------------------------#
#    引数｜ファイル名
#    　　　ENo
##-----------------------------------#
sub ParsePage{
    my $self        = shift;
    my $file_name   = shift;
    my $e_no        = shift;

    #結果の読み込み
    my $content = "";
    $content = &IO::FileRead($file_name);

    if (!$content) { return;}

    $content = &NumCode::EncodeEscape($content);
        
    #スクレイピング準備
    my $tree = HTML::TreeBuilder->new;
    $tree->parse($content);

    my $player_nodes           = &GetNode::GetNode_Tag_Attr("h2",    "id",    "player", \$tree);
    my $charadata_node         = $$player_nodes[0]->right;
    my $minieffect_nodes       = &GetNode::GetNode_Tag_Attr("div",   "class", "minieffect", \$charadata_node);
    my $status_nodes           = &GetNode::GetNode_Tag_Attr("table", "class", "charadata", \$tree);
    $status_nodes              = scalar(@$status_nodes) ? $status_nodes : &GetNode::GetNode_Tag_Attr("table", "class", "charadata2", \$tree); #機体プロフ絵ありのレイアウト対応
    my $spec_data_nodes        = &GetNode::GetNode_Tag_Attr("table", "class", "specdata", \$tree);
    my $nextday_h2_nodes       = &GetNode::GetNode_Tag_Attr("h2",    "id",    "nextday", \$tree);
    my $h3_nodes               = &GetNode::GetNode_Tag("h3", \$tree);
    my $charalist_table_nodes  = &GetNode::GetNode_Tag_Attr("table", "class", "charalist", \$tree);

    # データリスト取得
    if (exists($self->{DataHandlers}{Name}))         {$self->{DataHandlers}{Name}->GetData        ($e_no, $minieffect_nodes)};
    if (exists($self->{DataHandlers}{Status}))       {$self->{DataHandlers}{Status}->GetData      ($e_no, $$status_nodes[0])};
    if (exists($self->{DataHandlers}{Spec}))         {$self->{DataHandlers}{Spec}->GetData        ($e_no, $$spec_data_nodes[0])};
    if (exists($self->{DataHandlers}{Reward}))       {$self->{DataHandlers}{Reward}->GetData      ($e_no, $$nextday_h2_nodes[0]->right)};
    if (exists($self->{DataHandlers}{BattleSystem})) {$self->{DataHandlers}{BattleSystem}->GetData($e_no, $h3_nodes)};
    if (exists($self->{DataHandlers}{Intention}))    {$self->{DataHandlers}{Intention}->GetData   ($e_no, $h3_nodes)};
    if (exists($self->{DataHandlers}{Partnership}))  {$self->{DataHandlers}{Partnership}->GetData ($e_no, $h3_nodes, $$charalist_table_nodes[0])};

    $tree = $tree->delete;
}

#-----------------------------------#
#       該当ファイル数を取得
#-----------------------------------#
#    引数｜ディレクトリ名
#    　　　ファイル接頭辞
##-----------------------------------#
sub GetFileNo{
    my $directory   = shift;
    my $prefix    = shift;

    #ファイル名リストを取得
    my @fileList = grep { -f } glob("$directory/$prefix*.html");

    my $max= 0;
    foreach (@fileList) {
        $_ =~ /$prefix(\d+).html/;
        if ($max < $1) {$max = $1;}
    }
    return $max
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
