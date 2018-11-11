#===================================================================
#        CatalogData.tsv（マーケット情報）取得パッケージ
#-------------------------------------------------------------------
#            (C) 2018 @white_mns
#===================================================================


# パッケージの使用宣言    ---------------#   
use strict;
use warnings;
require "./source/lib/Store_Data.pm";
require "./source/lib/Store_HashData.pm";
use ConstData;        #定数呼び出し


#------------------------------------------------------------------#
#    パッケージの定義
#------------------------------------------------------------------#     
package CatalogData;

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
    $self->{Datas}{Item}  = StoreData->new();
    my $header_list = "";
   
    $header_list = [
                "result_no",
                "generate_no",
                "e_no",
                "market_no",
                "name",
                "kind",
                "unique_1",
                "unique_2",
                "ap",
                "spending_en",
                "value",
                "ammunition_cost",
                "weight",
                "turning_speed",
                "guard_elemental",
                "guard_value",
                "precision",
                "punding",
                "aerosol",
                "bullet",
                "loading",
                "weapon_element",
                "add_abnormity",
                "strength",
                "gunshot",
                "struggle",
                "reaction",
                "control",
                "preparation",
                "fitly",
                "type_id",
                "equip",
                "fuka_1",
                "fuka_2",
                "charge",
                "orig_name",
    ];

    $self->{Datas}{Item}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{Item}->SetOutputName( "./output/market/catalog_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜ファイル名
#-----------------------------------#
sub GetData{
    my $self         = shift;
    my $file_name    = shift;
    
    my $content   = &IO::FileRead ( $file_name );
    my @file_data = split(/\n/, $content);
    pop(@file_data); # フッタ行削除
    
    foreach my $data_set(@file_data) {
        my $data = [];
        @$data   = split(ConstData::SPLIT, $data_set);
        
        if (scalar(@$data) < 1 || !$$data[0] || !$$data[2]) {next;}

        $self->GetUnitData($data);
    } 
    
    return;
}

#-----------------------------------#
#    マーケットデータ取得
#------------------------------------
#    引数｜tsvデータ一行を分割した配列
#-----------------------------------#
sub GetUnitData{
    my $self         = shift;
    my $data         = shift;

    my $market_no = $$data[0];
    my $name = $$data[1];
    my $kind = $self->{CommonDatas}{ProperName}->GetOrAddId($$data[2]);
    my $unique_1 = $$data[3];
    my $unique_2 = $$data[4];
    my $ap = $$data[5];
    my $spending_en = $$data[6];
    my $value = $$data[7];
    my $ammunition_cost = $$data[8];
    my $weight = $$data[9];
    my $turning_speed = $$data[10];
    my $guard_elemental = $self->{CommonDatas}{ProperName}->GetOrAddId($$data[11]);
    my $guard_value = $$data[12];
    my $precision = $$data[13];
    my $punding = $$data[14];
    my $aerosol = $$data[15];
    my $bullet = $$data[16];
    my $loading = $$data[17];
    my $weapon_element = $self->{CommonDatas}{ProperName}->GetOrAddId($$data[18]);
    my $add_abnormity = $$data[19];
    my $strength = $$data[21];
    my $gunshot = $$data[22];
    my $struggle = $$data[23];
    my $reaction = $$data[24];
    my $control = $$data[25];
    my $preparation = $$data[26];
    my $fitly = $$data[27];
    my $type = $$data[28];
    my $equip = $$data[29];
    my $fuka_1 = $self->{CommonDatas}{ProperName}->GetOrAddId($$data[30]);
    my $fuka_2 = $self->{CommonDatas}{ProperName}->GetOrAddId($$data[31]);
    my $e_no = $$data[32];
    my $charge = $$data[34];
    my $orig_name = $self->{CommonDatas}{ProperName}->GetOrAddId($$data[36]);
    
    my @datas=($self->{ResultNo}, $self->{GenerateNo}, $e_no, $market_no, $name, $kind, $unique_1, $unique_2, $ap, $spending_en, $value, $ammunition_cost, $weight, $turning_speed, $guard_elemental, $guard_value, $precision, $punding, $aerosol, $bullet, $loading, $weapon_element, $add_abnormity, $strength, $gunshot, $struggle, $reaction, $control, $preparation, $fitly, $type, $equip, $fuka_1, $fuka_2, $charge, $orig_name);
    $self->{Datas}{Item}->AddData(join(ConstData::SPLIT, @datas));
    
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
