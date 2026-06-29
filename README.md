# glsl0 - 第１回 シェーダプログラムの読み込み 雛形プログラム

## 1. 概要

このプログラムは、OpenGL における「プログラマブルシェーダ (Programmable Shader)」および「GLSL (OpenGL Shading Language)」によるシェーダプログラムの読み込みの基礎を学ぶための、学生向けのサンプルプログラムです。本プログラムは、以下のブログ記事の解説に沿って学習を進めるための雛形として提供されています。

- [第１回 シェーダプログラムの読み込み](https://tokoik.github.io/blog/glsl%20%E5%85%A5%E9%96%80/2005/10/06/glsl.html)

現段階ではウィンドウ上に照明があたった１枚の四角形ポリゴンが表示されるだけのシンプルな内容となっています。マウスのドラッグ操作によって、表示されている四角形をぐるぐると回転させることができます。

![１枚の四角形](https://tokoik.github.io/blog/assets/images/glsl/glsl0.webp)

ブログ記事の手順に従って、このプログラムをプログラマブルシェーダを使って描画するように書き換えます。

## 2. ビルド方法

このプログラムは [CMake](https://cmake.org/) を用いてビルド環境を整備します。各OSとも、ソースコードが置かれているディレクトリにターミナル（またはコマンドプロンプト）で移動してから、以下の手順を実行してください。なお、プログラムをビルドするためのバイナリディレクトリは、バージョン管理ファイル（.gitignore）の設定に合わせて build という名前にします。

> cmake-gui で設定することも可能です。その際は、`Source code path` にはプロジェクトのフォルダを指定し、`Build path` にはプロジェクトのフォルダの中に作った build というフォルダを指定してください。その後、`Configure` → `Generate` の順にクリックした後、`Open Project` をクリックすれば、開発環境が起動するはずです。

### 2.1 Windows (Visual Studio 2022 の場合)

1. コマンドプロンプトまたは PowerShell を開き、このプロジェクトのディレクトリに移動します。
2. 以下のコマンドを実行してビルドディレクトリを作成し、CMake で構成を行います。

   ```bat
   mkdir build
   cd build
   cmake .. -G "Visual Studio 17 2022"
   ```

3. 生成された build フォルダ内の glsl0.sln を Visual Studio で開きます。
4. ソリューションエクスプローラーで **glsl0** プロジェクトを右クリックし、「スタートアップ プロジェクトに設定」を選択します。
5. 「ローカル Windows デバッガー」をクリックするか、F5 キーを押してビルドおよび実行します。

### 2.2 macOS (Xcode の場合)

1. ターミナルを開き、このプロジェクトのディレクトリに移動します。
2. 以下のコマンドを実行してビルドディレクトリを作成し、Xcode 用のプロジェクトを生成します。

   ```sh
   mkdir build
   cd build
   cmake .. -G Xcode
   ```

3. 生成された build/glsl0.xcodeproj を Xcode で開きます。
4. 左上のスキーム選択（再生ボタンの横）が **glsl0** になっていることを確認します。
5. 「Run」ボタン（再生ボタン）をクリックするか、Command + R を押してビルドおよび実行します。

### 2.3 Ubuntu Linux

1. ターミナルを開き、このプロジェクトのディレクトリに移動します。
2. 必要なパッケージ（freeglut3-dev など）がインストールされていることを確認し、以下のコマンドでビルドします。

   ```sh
   mkdir build
   cd build
   cmake ..
   make
   ```

## 3. 使い方

### 3.1 プログラムの起動方法

各OSとも、ビルド後に生成されるバイナリディレクトリ (build) やそのサブフォルダから起動します。（※ CMake の設定により、Windows や Xcode では Debug などのフォルダ下に実行ファイルが置かれることがあります）

- **Windows**

  Visual Studio 上で「ローカル Windows デバッガー」をクリックして実行するか、またはコマンドプロンプトから以下のコマンドで起動します。

  ```cmd
  cd build\Debug
  glsl0.exe
  ```

- **macOS**

  Xcode 上で左上の「Run（再生ボタン）」をクリックするのが楽です。これにより glsl0.app アプリケーションバンドルとして自動的に実行されます。アプリケーションバンドルを直接起動するなら、Finder から build/Debug/glsl0.app をダブルクリックするか、ターミナルから open build/Debug/glsl0.app を実行します (この場合はエラーメッセージ等が表示されません)。

- **Ubuntu Linux**

  ターミナルから以下のコマンドで実行ファイル（バイナリ）を直接起動します。

  ```sh
  cd build
  ./glsl0
  ```

### 3.2 操作方法

- **マウスの左ボタンでドラッグ**

  画面内のオブジェクト（四角形）を３次元的に回転させることができます。

- **キーボードの q, Q または ESC キー**

  プログラムを終了します。

## 4. 解説

このプログラムの主要なソースコードである main.cpp は、[OpenGL](https://www.opengl.org/) ([GLUT](https://www.opengl.org/resources/libraries/glut/spec3/spec3.html)) を用いた最も基本的な3次元グラフィックス描画プログラムの構造を持っています。実行される大まかな処理手順と、それぞれの関数がどのようなアルゴリズム・役割で行われているかを解説します。

### 4.1 `main()` 関数

プログラムの入り口です。初期化処理として GLUT のウィンドウ作成を行い、その後各イベント（毎フレームの描画、ウィンドウサイズ変更、マウス操作、キーボード入力など）が発生した際に呼び出されるコールバック関数をシステムに登録します。最後に [`glutMainLoop()`](https://www.opengl.org/resources/libraries/glut/spec3/node14.html) を呼び出すことで、イベント待ちの無限ループに入ります。以降は、登録された各関数が自動的に呼び出される形で処理が進みます。

### 4.2 `init()` 関数

プログラム起動後、描画ループに入る前に一度だけ呼ばれる初期設定です。
3D空間の背景色を設定し、隠面消去（手前の物体に隠れた奥の物体を描画しない処理 `GL_DEPTH_TEST`）を有効にしています。また、光源（ライト）の設定を行い、光の色・強さ（直接光や環境光）などを定義・有効化しています。

### 4.3 `scene()` 関数

実際に画面に表示される物体（3Dモデル）を描画する処理が書かれています。
glBegin(GL_QUADS) から glEnd() の間に、4つの頂点座標を [`glVertex3d()`](https://registry.khronos.org/OpenGL-Refpages/gl2.1/xhtml/glVertex.xml) によって指定することで、１枚の四角形ポリゴンを描画します。ここでは光の反射を計算するために glNormal3d() で法線ベクトル（面が向いている方向）を指定し、[`glMaterialfv()`](https://registry.khronos.org/OpenGL-Refpages/gl2.1/xhtml/glMaterial.xml) でポリゴン自体の材質（色）を設定しています。今後、この関数で描画される図形に対してシェーダプログラムを適用していくことになります。

### 4.4 `display()` 関数

画面全体の描画処理を行います（システムの描画要求ごとに呼び出されます）。
まずモデルビュー変換行列（被写体の位置や視点の向きを管理する行列）を初期化し、光源の位置を設定します。その後、視点を少し後ろに下げ、トラックボール処理で図形を回転させる行列を掛け合わせることで、オブジェクトの姿勢を決定します。画面（カラーバッファとデプスバッファ）をまっさらな状態にクリアした上で scene() を呼び出し、内部で描画したものを [`glutSwapBuffers()`](https://www.opengl.org/resources/libraries/glut/spec3/node21.html) で画面に表示します（ちらつきを抑えるダブルバッファリングという手法です）。

### 4.5 `resize()` 関数

ウィンドウのサイズが変更されたり、最初にウィンドウが開かれた際に呼ばれます。
変更されたウィンドウサイズに合わせて描画領域（ビューポート）を合わせ、カメラのレンズに相当する透視投影（パースペクティブ）の行列設定を行います。これにより、ウィンドウを引き伸ばしても図形が歪まないように調整されます。

### 4.6 `mouse()`, `motion()` 関数

マウスによるドラッグ操作を処理します。これらの関数は専用のトラックボール処理プログラムと連携し、クリックした座標と動かした座標の差分からオブジェクトを回転させるための計算を行っています。

### 4.7 `keyboard()` 関数

キーボードの入力を受け取ります。本プログラムでは、ESC キーや 'q' キーが押されたときに `exit(0)` を呼び出し、プログラムを安全に終了させる役割を担っています。

### 4.8 `idle()` 関数

プログラムが他に処理をしていない空き時間に呼ばれ続けます。常に画面を再描画する指示 ([`glutPostRedisplay()`](https://www.opengl.org/resources/libraries/glut/spec3/node20.html)) を出しているため、マウスを操作している間にオブジェクトがスムーズにアニメーション（回転）するようになります。

### 4.9 glsl.cpp, glsl.h (シェーダ制御用ヘルパー)

GLSL シェーダの初期化、ソースプログラムの読み込み、およびコンパイル・リンク時のエラーログ出力などを行うヘルパー関数群です。
- [`glslInit()`](https://github.com/tokoik/glsl0/blob/main/glsl.cpp#L110-L217): Windows 環境向けに GLSL 関連の各種関数ポインタ（拡張機能のエントリポイント）を取得・初期化します。
- [`readShaderSource()`](https://github.com/tokoik/glsl0/blob/main/glsl.cpp#L222-L262): ファイルからシェーダのソースコードを読み込み、シェーダオブジェクトに転送します。
- [`printShaderInfoLog()`](https://github.com/tokoik/glsl0/blob/main/glsl.cpp#L267-L287) / [`printProgramInfoLog()`](https://github.com/tokoik/glsl0/blob/main/glsl.cpp#L292-L312): コンパイルエラーやリンクエラーが発生した際に、GPU ドライバーから出力される詳細なデバッグ用ログ（インフォログ）を標準エラー出力へ表示します。

### 4.10 trackball.cpp, trackball.h (トラックボール制御)

マウスのドラッグ操作によって、画面内の3次元オブジェクトを直感的に回転させるためのトラックボール計算ライブラリです。
- [`trackballInit()`](https://github.com/tokoik/glsl0/blob/main/trackball.cpp#L93-L106): 回転状態を初期化します。
- [`trackballRegion()`](https://github.com/tokoik/glsl0/blob/main/trackball.cpp#L112-L117): マウスドラッグを追跡するためのウィンドウサイズ情報を設定します。
- [`trackballStart()`](https://github.com/tokoik/glsl0/blob/main/trackball.cpp#L123-L131) / [`trackballStop()`](https://github.com/tokoik/glsl0/blob/main/trackball.cpp#L170-L183): マウスボタンの押し下げ・解放時に呼び出し、回転開始点および終了点を記録します。
- [`trackballMotion()`](https://github.com/tokoik/glsl0/blob/main/trackball.cpp#L137-L164): マウスドラッグ中の移動量をクォータニオンを用いた仮想トラックボールの回転量に変換します。
- [`trackballRotation()`](https://github.com/tokoik/glsl0/blob/main/trackball.cpp#L189-L192): 現在の回転状態を OpenGL の変換行列（4x4の倍精度実数配列）の形式で取得します。

### 4.11 simple.vert (バーテックスシェーダ)

頂点処理を行うシェーダファイルです。
- [`ftransform()`](https://github.com/tokoik/glsl0/blob/main/simple.vert#L8) を呼び出すことで、従来の OpenGL 固定機能におけるモデルビュー変換および投影変換と同じ処理を行い、頂点のクリッピング座標を決定しています。

### 4.12 simple.frag (フラグメントシェーダ)

ピクセル（フラグメント）の彩色処理を行うシェーダファイルです。
- 固定値 `vec4(1.0, 0.0, 0.0, 1.0)` を [`gl_FragColor`](https://github.com/tokoik/glsl0/blob/main/simple.frag#L8) に代入することで、すべての描画対象ピクセルを赤色（不透明）に設定しています。
