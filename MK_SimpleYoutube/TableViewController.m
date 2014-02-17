//
//  TableViewController.m
//  MK_SimpleYoutube
//
//  Created by MurataKazuki on 2013/11/27.
//  Copyright (c) 2013年 MK. All rights reserved.
//

#import "TableViewController.h"

@interface TableViewController (){
    //Youtubeから読み込むデータを格納するNSArray
    NSArray *_objects;
}
//searchBar参照用のプロパティ
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation TableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

//searchBarで検索ボタンをおした際に呼び出されるメソッド
- (void)searchBarSearchButtonClicked:(UISearchBar*)searchBar
{
    //searchBarからフォーカスを外す（＝キーボードが隠れる）
    [searchBar resignFirstResponder];
    //入力された文字でYoutube検索を行う
    [self searchWord:searchBar.text];
    
    
    
}

//指定した文字列を引数にYoutubeを検索するメソッド
-(void)searchWord:(NSString *)text{
    //*******************
    // URLの準備
    //*******************
    NSLog(@"original text=%@",text);
    //URLエンコーディング
    text = [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"encoded text=%@",text);
    
    //Youtubeに対して、検索をかける文字列
    //（Web APIとしてURLの記述方法が決まっている）
    NSString *urlString = [NSString stringWithFormat:@"http://gdata.youtube.com/feeds/api/videos?v=2&orderby=viewCount&max-results=10&alt=json&q=%@",text];
    
    //データを読み取るためにNSURL
    NSURL *url = [NSURL URLWithString:urlString];

    //*******************
    // JSONデータの取得
    //*******************
    //エラー情報
    NSError *error;

    //URLに対してNSDataで結果を取得する
    NSData *jsonData = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
    //エラー時はエラー内容を表示して終了
    if (error) {
        NSLog(@"error=%@",error);
        return;
    }
    //*******************
    // データへの変換と格納
    //*******************
    //データが取得できた場合には、NSDicrionaryに格納
    //（Web APIで戻されるデータが決まっている）
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    
    //Youtubeは結果が複雑なので必要な箇所だけを修得
    _objects = dic[@"feed"][@"entry"];
    

    //テーブル表示を更新させる（cellの表示が行われる）
    [self.tableView reloadData];
}

#pragma mark - Table view data source

//セルの行数はデータの個数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_objects count];
}

//セルの描画
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //StoryBoardで作成したセルオブジェクトの取得
    //（"Cell"というIdentifierが設定されている）
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    //*******************
    // セルデータの取得
    //*******************
    //データ内の、表示する行データを取得
    NSDictionary *record = (NSDictionary *)_objects[indexPath.row];
    
    //*******************
    // サムネイル画像の表示
    //*******************
    //サムネイルを表示するimageViewを取得（StoryBoard上でTag:111が設定されている）
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:111];
    //（JSONデータから表示したいurlを設定）
    NSString *urlString = record[@"media$group"][@"media$thumbnail"][0][@"url"];
    NSLog(@"thumbnail url=%@",urlString);

    //サムネイル画像をNSDataにダウンロードし、imageViewに設定
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
    imageView.image = [UIImage imageWithData:imageData];

    //*******************
    // タイトル文字列の表示
    //*******************
    //タイトルを表示するラベルを取得し（StoryBoard上でTag:222が設定されている）、タイトルの文字を設定
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:222];
    //（JSONデータから表示したい箇所を設定）
    titleLabel.text = record[@"title"][@"$t"];
    
    return cell;
}

//セルタッチ次に呼び出されるメソッド
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //データ内の、表示する行データを取得
    NSDictionary *record = (NSDictionary *)_objects[indexPath.row];
    
    //（JSONデータから表示したいvideoIdを取得）
    NSString *videoId = record[@"media$group"][@"yt$videoid"][@"$t"];
    NSLog(@"videoId=%@",videoId);

    //videoIdを引数としてyoutubeアプリを起動
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"youtube:%@",videoId]];
    [[UIApplication sharedApplication] openURL:url];
}
@end
