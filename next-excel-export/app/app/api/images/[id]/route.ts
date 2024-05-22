import { NextRequest, NextResponse } from 'next/server';
import path from 'path';
import fs from 'fs';

export const GET = async (req: NextRequest, { params }: { params: {id: string} } ) => {
  const { id } = params;
  const imgPath = path.join(process.cwd(), 'public', `${id}.jpeg`);
  console.log(imgPath)
  if(fs.existsSync(imgPath)) {
    const image = fs.readFileSync(imgPath);
    return new NextResponse(image, {
        headers: {
            'Content-Type': 'image/jpeg',
        },
    });
  } else {
    return new NextResponse('File Not Found', {
        status: 404,
    });
  }
}