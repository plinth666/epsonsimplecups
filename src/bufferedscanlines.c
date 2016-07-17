/*
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

/*
 * These are a set of routines that provide the ability to buffer up
 * scanlines for writing in bulk.
 *
 * Original version, Steve Hawley, 5/10/2015
 */

#include <malloc.h>
#include <string.h>
#include "bufferedscanlines.h"

/*
 * private routine to clear a buffer and reset the currentRow
 */
static void bufferscan_reset(t_bufferscan *bs)
{
	if (!bs) return;
	int totalBytes;

	if (!bs) return;
	totalBytes = bs->bytesPerRow * bs->currentRow;
	bs->currentRow = 0;
	memset(bs->rawData, 0, totalBytes);
}

/*
 * Allocate and reset a new bufferscan object.
 * Returns NULL on failure.
 */
t_bufferscan *bufferscan_new(int bytesperrow, int rows, int outputFlags, FILE *fp)
{
	t_bufferscan *bs = (t_bufferscan *)malloc(sizeof(t_bufferscan));
	if (!bs) return 0;

	bs->bytesPerRow = bytesperrow;
	bs->currentRow = 0;
	bs->totalRows = rows;
	bs->outputFlags = outputFlags;
	bs->fp = fp;
	bs->rawData = (unsigned char *)malloc(bytesperrow * rows);
	if (!bs->rawData)
	{
		free(bs);
		return 0;
	}
	bufferscan_reset(bs);
	return bs;
}

/*
 * Dispose an existing bufferscan and its memory.
 * This will not close the associated FILE.
 */
void bufferscan_dispose(t_bufferscan *bs)
{
	if (!bs) return;
	free(bs->rawData);
	free(bs);
}

/*
 * Adds a line to the buffer at currentRow. When currentRow is
 * advanced to totalRows, then flush out the current data.
 */
void bufferscan_addline(t_bufferscan *bs, unsigned char *data)
{
	unsigned char *dest = 0;
	if (!bs || !data) return;
	dest = bs->rawData + (bs->bytesPerRow * bs->currentRow);
	memcpy(dest, data, bs->bytesPerRow);
	bs->currentRow++;
	if (bs->currentRow == bs->totalRows)
		bufferscan_flush(bs);
}

/*
 * Flushes out any existing data in a bufferscan to the printer
 * and resets the bufferscan. This can be called at any time, but it
 * will be called automatically by adding lines.
 */
void bufferscan_flush(t_bufferscan *bs)
{
	int totalBytes;
	int i;

	if (!bs) return;
	if (bs->currentRow == 0) return;
	totalBytes = bs->bytesPerRow * bs->currentRow;

	/*
	 * Image data is represented by a small header block and then a chunk o
	 * of raw bitmap data.
	 * The format is:
	 * <29>8L<datalen>0p0<1><1>1<xl><xh><yl><yh><raw-data>
     * values in angle brackets are integer values. In this form,
	 * datalen is a 4 byte integer that represents the length of all
     * data that follows immediately after, including the format and
	 * width/height descriptors.
	 * datalen is 10 + (bytes wide * rows high).
	 * The 10 comes from all the information after <datalen> before <raw-data> 
 	 */

	fputc(29, bs->fp); fputc('8', bs->fp); fputc('L', bs->fp);
	writeLong(totalBytes + 10, bs->fp);
    fputc('0', bs->fp); fputc('p', bs->fp);
	fputc('0', bs->fp);
	fputc(bs->outputFlags & kDoubleWide ? 2 : 1, bs->fp);
	fputc(bs->outputFlags & kDoubleHigh ? 2 : 1, bs->fp);
	fputc('1', bs->fp);
	writeShort(bs->bytesPerRow * 8, bs->fp);
	writeShort(bs->currentRow, bs->fp);

	fwrite(bs->rawData, 1, totalBytes, bs->fp);
	fputc(29, bs->fp); fputc('(', bs->fp); fputc('L', bs->fp);
	fputc(2, bs->fp); fputc(0, bs->fp); fputc('0', bs->fp); fputc('2', bs->fp);
	bufferscan_reset(bs);
}

/* write nbytes of an int in little endian form */
void writeInt(int n, int nbytes, FILE *fp)
{
    int i;
    for (i=0; i < nbytes; i++) {
		fputc(n & 0xff, fp);
        n = n >> 8;
    }
}


