#===================================================================
#    データベースへのアップロード
#-------------------------------------------------------------------
#        (C) 2018 @white_mns
#===================================================================

# モジュール呼び出し    ---------------#
require "./source/Upload.pm";
require "./source/lib/time.pm";

# パッケージの使用宣言    ---------------#
use strict;
use warnings;
require LWP::UserAgent;
use HTTP::Request;
use HTTP::Response;

# 変数の初期化    ---------------#
use ConstData_Upload;        #定数呼び出し

my $timeChecker = TimeChecker->new();

# 実行部    ---------------------------#
$timeChecker->CheckTime("start  \t");

&Main;

$timeChecker->CheckTime("end    \t");
$timeChecker->OutputTime();
$timeChecker = undef;

# 宣言部    ---------------------------#

sub Main {
    my $result_no = $ARGV[0];
    my $generate_no = $ARGV[1];
    my $upload = Upload->new();

    if (!defined($result_no) || !defined($generate_no)) {
        print "error:empty result_no or generate_no";
        return;
    }

    $upload->DBConnect();
    
    if (ConstData::EXE_DATA) {
        &UploadData($upload, ConstData::EXE_DATA_PROPER_NAME, "proper_names", "./output/data/proper_name.csv");
    }
    if (ConstData::EXE_MARKET) {
        &UploadResult($upload, $result_no, $generate_no, ConstData::EXE_DATA_PROPER_NAME, "markets", "./output/market/catalog_");
    }
    if (ConstData::EXE_CHARA) {
        &UploadResult($upload, $result_no, $generate_no, ConstData::EXE_CHARA_NAME,         "names",         "./output/chara/name_");
        &UploadResult($upload, $result_no, $generate_no, ConstData::EXE_CHARA_ITEM,         "items",         "./output/chara/item_");
        &UploadResult($upload, $result_no, $generate_no, ConstData::EXE_CHARA_STATUS,       "statuses",      "./output/chara/status_");
        &UploadResult($upload, $result_no, $generate_no, ConstData::EXE_CHARA_SPEC,         "specs",         "./output/chara/spec_");
        &UploadResult($upload, $result_no, $generate_no, ConstData::EXE_CHARA_CONDITION,    "conditions",    "./output/chara/condition_");
        &UploadResult($upload, $result_no, $generate_no, ConstData::EXE_CHARA_REWARD,       "rewards",       "./output/chara/reward_");
        &UploadResult($upload, $result_no, $generate_no, ConstData::EXE_CHARA_REGALIA,      "regalia",       "./output/chara/regalia_");
        &UploadResult($upload, $result_no, $generate_no, ConstData::EXE_CHARA_INTENTION,    "intentions",    "./output/chara/intention_");
        &UploadResult($upload, $result_no, $generate_no, ConstData::EXE_CHARA_PARTNERSHIP,  "partnerships",  "./output/chara/partnership_");
        &UploadResult($upload, $result_no, $generate_no, ConstData::EXE_CHARA_ASSEMBLY_NUM, "assembly_nums", "./output/chara/assembly_num_");
    }
    if (ConstData::EXE_CHARALIST) {
        &UploadResult($upload, $result_no, $generate_no, ConstData::EXE_CHARALIST_NEXT_BATTLE, "next_battles", "./output/charalist/next_battle_");
    }
    if (ConstData::EXE_BATTLE) {
        &UploadResult($upload, $result_no, $generate_no, ConstData::EXE_BATTLE_BLOCK,      "blocks",      "./output/battle/block_");
        &UploadResult($upload, $result_no, $generate_no, ConstData::EXE_BATTLE_TRANSITION, "transitions", "./output/battle/transition_");
    }
    print "result_no:$result_no,generate_no:$generate_no\n";
    return;
}

#-----------------------------------#
#       結果番号に依らないデータをアップロード
#-----------------------------------#
#    引数｜アップロードオブジェクト
#    　　　アップロード定義
#          テーブル名
#          ファイル名
##-----------------------------------#
sub UploadData {
    my ($upload, $is_upload, $table_name, $file_name) = @_;

    if ($is_upload) {
        $upload->DeleteAll($table_name);
        $upload->Upload($file_name, $table_name);
    }
}

#-----------------------------------#
#       更新結果データをアップロード
#-----------------------------------#
#    引数｜アップロードオブジェクト
#    　　　更新番号
#    　　　再更新番号
#    　　　アップロード定義
#          テーブル名
#          ファイル名
##-----------------------------------#
sub UploadResult {
    my ($upload, $result_no, $generate_no, $is_upload, $table_name, $file_name) = @_;

    if($is_upload) {
        $upload->DeleteSameResult($table_name, $result_no, $generate_no);
        $upload->Upload($file_name . $result_no . "_" . $generate_no . ".csv", $table_name);
    }
}
