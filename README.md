HTTPのセッション管理を自分で行うテスト
======================================

ライブラリやフレームワークを使っていると、ウェブページでのセッション管理が実際に
どのように行われているのかわからない。
そこで基本的な機能のみを使ってセッション管理を行ってみる。

# ノート
## サーバ

* Rubyの[TCPServer](http://docs.ruby-lang.org/ja/2.2.0/class/TCPServer.html)を使い、
  HTTPリクエストを受け取り、レスポンスを返す。

## セッション

* HTTPはリクエストごとに独立したものになっていて、同一ユーザからの連続したアクセスを判断することができない
  * URLに埋め込めばできるけど、セキュリティ的によろしくない
* クッキーという仕組みを使って実現する

### クッキー

* セッションなんてものはない、あるのはクッキー
* HTTPレスポンスヘッダとして`Set-Cookie: NAME=VALUE`と指定するとブラウザは(ドメイン|URL)に対してクッキーを保存する
  * `Set-Cookie: NAME=VALUE; expires=...`でクッキーの有効期限を設定することができる
    * 日付のフォーマットは`曜日, 日 月 年 時:分:秒 タイムゾーン` ex.`strftime('%a, %d %b %Y %H:%M:%S %Z')`
* 次回アクセス時に、ブラウザはクッキーをHTTPリクエストヘッダに
  `Cookie: NAME=VALUE; NAME2=VALUE2; ...`という形式で渡すので、サーバ側で受け取ることができる

### クッキーでセッションを実装する

* クッキーにセッションを識別するID（セッションID）を保存して、ブラウザからのアクセス時にサーバに送られ、
  サーバ側でそれに基づいて処理することができる


# ライブラリはどのようにセッションを実装しているか
## Ruby/CGI/Session

* ソース：[ruby/lib/cgi/session.rb](https://github.com/ruby/ruby/blob/trunk/lib%2Fcgi%2Fsession.rb)

.
