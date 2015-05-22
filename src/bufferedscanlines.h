#ifndef _H_BufferedScanlines
#define _H_BufferedScanlines
#pragma once


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
 *
 * Original version, Steve Hawley, 5/10/2015
 */

#include <stdio.h>

/*
 * basic definition for a buffer of scanlines.
 * This is more or less a typical 1-bit byte-padded bitmap
 * with state information for the current row that needs to
 * be buffered and the output FILE.
 *
 * In theory, the bitmap, the state, and the output should
 * be different entities to prevent interdependence, but
 * honestly, this code is so dead-simple, any additional
 * abstraction takes away from the readability.
 */
typedef struct t_bufferscan {
	int bytesPerRow;
	int totalRows;
	int currentRow;
	int outputFlags;
	FILE *fp;
	unsigned char *rawData;
} t_bufferscan;

/*
 * This is the primary API for buffering up scanlines.
 * There is a constructor/destructor set, a routine for adding a line,
 * a routine to flush the current buffer out, and a routine for writing
 * little endian integers as binary data.
 */

/*
 * defines flags for setting double width/height
 */
enum {
	kDoubleWide = 1,
	kDoubleHigh = 2
};

/* constructs a new t_bufferscan with the given bytesperrow, the total number of rows,
 * and the output FILE. Returns NULL on failure. Internally, this will allocate memory
 * for the buffer.
 */
extern t_bufferscan *bufferscan_new(int bytesperrow, int rows, int outputFlags, FILE *fp);
/* destructure the t_bufferscan and its contents. Does NOT close the output FILE */
extern void bufferscan_dispose(t_bufferscan *bs);

/* adds a line to the current buffer. If this action fills the buffer, the code
 * will automatically flush the buffer.
 */
extern void bufferscan_addline(t_bufferscan *bs, unsigned char *data);
/* writes the buffered scanlines out as an image consumable by an EPSON TM-T20 printer.
 */
extern void bufferscan_flush(t_bufferscan *bs);

/*
 * Writes nByes of the integer in little endian format to the FILE
 */
extern void writeInt(int n, int nbytes, FILE *fp);

/*
 * Macros for short and long
 */
#define writeShort(n, fp) writeInt(n, 2, fp)
#define writeLong(n, fp) writeInt(n, 4, fp)

#endif
