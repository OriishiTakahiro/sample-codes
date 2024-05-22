'use client'
import axios from 'axios';
import ExcelJS from 'exceljs';
import { useState, useEffect, } from 'react';

const sampleImages = [
  'http://localhost:3000/api/images/1',
  'http://localhost:3000/api/images/2',
  'http://localhost:3000/api/images/3',
  'http://localhost:3000/api/images/4',
  'http://localhost:3000/api/images/5',
]

const Home = () => {

  const [sheetUrl, setSheetUrl] = useState<string>('');

  useEffect(() => {
    (async() => {
    // 画像を取得してbase64に変換
    const fetchedImages = await Promise.all(
      sampleImages.map(url => axios.get(url, {responseType: 'arraybuffer'}).then(res => 
        Buffer.from(res.data, 'binary').toString('base64')
      ))
    );
    // Excelファイルを作成
    const workbook = new ExcelJS.Workbook();
    workbook.addWorksheet('Sheet1');
    const sheet = workbook.worksheets[0];
    // ヘッダーを設定
    sheet.columns = [
      {header: '到達速度 [km/h]', key: 'speed', width: 20},
      {header: '加速度 [km/h/sec]', key: 'acc', width: 20},
      {header: '観測点', key: 'spot', width: 20},
      {header: '画像', key: 'img1', width: 60},
      {header: '画像', key: 'img2', width: 60},
      {header: '画像', key: 'img3', width: 60},
      {header: '画像', key: 'img4', width: 60},
      {header: '画像', key: 'img5', width: 60},
    ]
    // 画像列のヘッダを結合
    sheet.mergeCells('D1:H1')
    sheet.addRows(
      [
        {speed: 100, acc: 1, spot: 1},
        {speed: 100, acc: 5, spot: 2},
        {speed: 100, acc: 10, spot: 1},
        {speed: 150, acc: 1, spot: 1},
        {speed: 150, acc: 5, spot: 2},
        {speed: 150, acc: 10, spot: 3},
      ]
    )
    console.log(fetchedImages)
    const imageIds = fetchedImages.map((e) => workbook.addImage({base64: e, extension: 'jpeg'}));
    const imageSizes = fetchedImages.map((e) => {
      const img = new Image();
      img.src = `data:image/jpeg;base64,${e}`;
      return {width: img.width, height: img.height}
    });

    for(let row = 0; row < 6; row++) {
      for(let col = 0; col < 5; col++) {
        sheet.addImage(imageIds[col], {
          // 画像の配置位置を指定 (なんか1.5とかよくわからんのもできるらしい)
          tl: { col: col + 3, row: row + 1 },
        // 画像のサイズが大きいのでいい感じに小さくする
          ext: {width: imageSizes[col].width*0.5, height: imageSizes[col].height*0.5},
          // hyperlinksを設定すると画像にリンクが設定される
          // hyperlinks: {hyperlink: sampleImages[col]},
          editAs: 'undefined'
        })
      }
    }

    imageSizes.forEach((size, i) => {
      // 画像とカラムの単位関係がわかっていないのでマジックナンバーで対応
      sheet.getColumn(4 + i).width = size.width*0.08;
    });
    const maxHeight = Math.max(...imageSizes.map(e => e.height));
    // 画像とカラムの単位関係がわかっていないのでマジックナンバーで対応
    sheet.getRows(2, 6)?.forEach(row => { row.height = maxHeight*0.3; });

    const uint8Array = await workbook.xlsx.writeBuffer();
    const blob = new Blob([uint8Array], {type: 'application/octet-binary'});
    const fileUrl = window.URL.createObjectURL(blob)
    console.log(fileUrl)
    setSheetUrl(fileUrl);
    })();
  }, [])

  return (
    <>
        <a href={sheetUrl} download='sample.xlsx'>Click Here</a>
    </>
  );
}

export default Home;