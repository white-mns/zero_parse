# ゼロ城試遊会データ小屋　解析プログラム
ゼロ城試遊会データ小屋は[ゼロの城砦](http://blacktea.sakura.ne.jp/teaconvini/)を解析して得られるデータを扱った情報サイトです。  
このプログラムはゼロ城試遊会データ小屋で実際に使用している解析・DB登録プログラムです。  
データ小屋の表示部分については[別リポジトリ](https://github.com/white-mns/zero_rails)を参照ください。

# サイト
実際に動いているサイトです。  
[ゼロ城試遊会データ小屋](http://data.teiki.org/zero_0)

# 動作環境
以下の環境での動作を確認しています  
  
OS:CentOS release 6.5 (Final)  
DB:MySQL  
Perl:5.10.1  

## 必要なもの

bashが使えるLinux環境。（Windowsでやる場合、execute.shの処理を手動で行ってください）  
perlが使える環境  
デフォルトで入ってないモジュールを使ってるので、

    cpan DateTime

みたいにCPAN等を使ってDateTimeやHTML::TreeBuilderといった足りないモジュールをインストールしてください。

## 使い方
圧縮ファイルをダウンロードして`data/utf`に置きます。ゼロ城ではここは手動です。  

第一回更新なら

    ./execute.sh 1

とします。
最更新が1回あって圧縮ファイルが`002.zip`、`002_1.zip`となっている場合、その数字に合わせて

    ./execute.sh 2 0
    ./execute.sh 2 1

とすることで再更新前、再更新後を指定することが出来ます。
（ただし、データ小屋では仕様上、再更新前、再更新後のデータを同時に登録しないようにしています）  
上手く動けばoutput内に中間ファイルcsvが生成され、指定したDBにデータが登録されます。
`ConstData.pm`及び`ConstData_Upload.pm`を書き換えることで、処理を実行する項目を制限できます。

## DB設定
`source/DbSetting.pm`にサーバーの設定を記述します。  
DBのテーブルは[Railsアプリ側](https://github.com/white-mns/zero_rails)で`rake db:migrate`して作成しています。

## 中間ファイル
DBにアップロードしない場合、固有名詞を数字で置き換えている箇所があるため、csvファイルを読むのは難しいと思います。

    $$common_datas{ProperName}->GetOrAddId($$data[2])

のような`GetorAddId`、`GetId`関数で変換していますので、似たような箇所を全て

    $$data[2]

のように中身だけに書き換えることで元の文字列がcsvファイルに書き出され読みやすくなります。

## ライセンス
本ソフトウェアはMIT Licenceを採用しています。 ライセンスの詳細については`LICENSE`ファイルを参照してください。
