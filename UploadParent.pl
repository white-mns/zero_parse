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
        if (ConstData::EXE_DATA_PROPER_NAME) {
            $upload->DeleteAll('proper_names');
            $upload->Upload("./output/data/proper_name.csv", 'proper_names');
        }
    }
    if (ConstData::EXE_MARKET) {
        $upload->DeleteSameResult('markets', $result_no, $generate_no);
        $upload->Upload("./output/market/catalog_" . $result_no . "_" . $generate_no . ".csv", 'markets');
    }
    if (ConstData::EXE_CHARA) {
        if (ConstData::EXE_CHARA_NAME) {
            $upload->DeleteSameResult('names', $result_no, $generate_no);
            $upload->Upload("./output/chara/name_" . $result_no . "_" . $generate_no . ".csv", 'names');
        }
        if (ConstData::EXE_CHARA_ITEM) {
            $upload->DeleteSameResult('items', $result_no, $generate_no);
            $upload->Upload("./output/chara/item_" . $result_no . "_" . $generate_no . ".csv", 'items');
        }
        if (ConstData::EXE_CHARA_STATUS) {
            $upload->DeleteSameResult('statuses', $result_no, $generate_no);
            $upload->Upload("./output/chara/status_" . $result_no . "_" . $generate_no . ".csv", 'statuses');
        }
        if (ConstData::EXE_CHARA_SPEC) {
            $upload->DeleteSameResult('specs', $result_no, $generate_no);
            $upload->Upload("./output/chara/spec_" . $result_no . "_" . $generate_no . ".csv", 'specs');
        }
        if (ConstData::EXE_CHARA_CONDITION_ALL_TEXT) {
            $upload->DeleteSameResult('condition_all_texts', $result_no, $generate_no);
            $upload->Upload("./output/chara/condition_all_text_" . $result_no . "_" . $generate_no . ".csv", 'condition_all_texts');
        }
        if(ConstData::EXE_CHARA_REWARD) {
            $upload->DeleteSameResult('rewards', $result_no, $generate_no);
            $upload->Upload("./output/chara/reward_" . $result_no . "_" . $generate_no . ".csv", 'rewards');
        }
        if(ConstData::EXE_CHARA_REGALIA) {
            $upload->DeleteSameResult('regalias', $result_no, $generate_no);
            $upload->Upload("./output/chara/regalia_" . $result_no . "_" . $generate_no . ".csv", 'regalias');
        }
        if(ConstData::EXE_CHARA_INTENTION) {
            $upload->DeleteSameResult('intentions', $result_no, $generate_no);
            $upload->Upload("./output/chara/intention_" . $result_no . "_" . $generate_no . ".csv", 'intentions');
        }
        if(ConstData::EXE_CHARA_PARTNERSHIP) {
            $upload->DeleteSameResult('partnerships', $result_no, $generate_no);
            $upload->Upload("./output/chara/partnership_" . $result_no . "_" . $generate_no . ".csv", 'partnerships');
        }
        if(ConstData::EXE_CHARA_ASSEMBLY_NUM) {
            $upload->DeleteSameResult('assembly_nums', $result_no, $generate_no);
            $upload->Upload("./output/chara/assembly_num_" . $result_no . "_" . $generate_no . ".csv", 'assembly_nums');
        }
        
    }
    if (ConstData::EXE_CHARALIST) {
        if (ConstData::EXE_CHARALIST_NEXT_BATTLE) {
            $upload->DeleteSameResult('next_battles', $result_no, $generate_no);
            $upload->Upload("./output/charalist/next_battle_" . $result_no . "_" . $generate_no . ".csv", 'next_battles');
        }
    }
    if (ConstData::EXE_BATTLE) {
        if(ConstData::EXE_BATTLE_BLOCK) {
            $upload->DeleteSameResult('blocks', $result_no, $generate_no);
            $upload->Upload("./output/battle/block_" . $result_no . "_" . $generate_no . ".csv", 'blocks');
        }
        if(ConstData::EXE_BATTLE_TRANSITION) {
            $upload->DeleteSameResult('transitions', $result_no, $generate_no);
            $upload->Upload("./output/battle/transition_" . $result_no . "_" . $generate_no . ".csv", 'transitions');
        }
    }
    print "result_no:$result_no,generate_no:$generate_no\n";
    return;
}

