# this file is part of mftrace - a tool to generate scalable fonts from bitmaps  
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2
# as published by the Free Software Foundation
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Library General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc.,
#  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA 

# Copyright (c)  2001--2006 by
#  Han-Wen Nienhuys, Jan Nieuwenhuizen


##use like in mftrace: metric = tfm.read_tfm_file (options.tfm_file)
##metric_width = metric.get_char (a).width
##size = metric.design_size

import sys

def compose_tfm_number (seq):
    shift = (len (seq)-1)*8

    cs = 0L
    for b in seq:
        cs = cs  + (long (ord (b)) << shift)
        shift = shift - 8
    return cs

#
#
# Read params, ligatures, kernings. 
#
#
class Tfm_reader:
    def get_string (self):
        b = ord (self.left[0])
        s =self.left[1:1 + b]
        self.left = self.left[1+b:]
        
        return s
    def get_byte (self):
        b = self.left [0]
        self.left= self.left[1:]
        return ord(b)

    def extract_fixps (self, count):
        fs = [0.0] * count
        
        for c in range (0,count):
            fs[c]  = self.get_fixp_number ()

        return fs

    def extract_chars (self):
        count = self.end_code - self.start_code + 1
        fs = [None] * count
        
        for c in range (0,count):
            w = self.get_byte()
            b = self.get_byte()
            h = (b & 0xf0) >> 4
            d = (b & 0x0f)

            b = self.get_byte ()

            # huh? why >> 6 ? 
            i = (b & 0xfc) >> 6
            tag = (b & 0x3)
            rem = self.get_byte ()

            # rem is used as index for the ligature table.
            # TODO.
            lig = None
            
            fs[c] = (w, h, d, i, lig)
            
        return fs

    def get_ligatures(self):
        return None
    def get_kern_program (self):
        return None
    
    def __init__ (self, f):
        self.string = f
        self.left = f

        self.file_length = self.get_number (2);
        self.head_length = self.get_number (2);
        self.start_code =  self.get_number (2);
        self.end_code =  self.get_number (2);
        self.width_count = self.get_number (2);
        self.height_count =self.get_number(2);
        self.depth_count = self.get_number (2);
        self.italic_corr_count = self.get_number(2);
        self.ligature_kern_count = self.get_number (2);
        self.kern_count = self.get_number (2)
        self.extensible_word_count =self.get_number (2);
        self.parameter_count =self.get_number (2);
        
        self.checksum = self.get_number (4)
        self.design_size = self.get_fixp_number ()
        self.coding = self.get_string ()

        self.left =f[(6 + self.head_length) * 4:]
        self.chars = self.extract_chars ()
        self.widths = self.extract_fixps (self.width_count)
        self.heights = self.extract_fixps (self.height_count)
        self.depths = self.extract_fixps (self.depth_count)
        self.italic_corrections = self.extract_fixps (self.italic_corr_count)
        self.ligatures = self.get_ligatures ()
        self.kern_program = self.get_kern_program()

        del self.left

    def get_number (self, len):
        n = compose_tfm_number (self.left [0:len])
        self.left = self.left[len:]
        return n

    def get_fixp_number (self):
        n = self.get_number (4)
        n = n /16.0 / (1<<16);
        
        return n

    def get_tfm (self):
        keys  = ['start_code', 'end_code', 'checksum', 'design_size', 'coding', 'chars', 'widths', 'heights', 'depths', 'italic_corrections', 'ligatures', 'kern_program']
        tfm = Tex_font_metric ()
        for k in keys:
            tfm.__dict__[k] = self.__dict__[k]
        return tfm



class Char_metric:
    def __init__(self, tfm, tup):
        (w, h, d, i, lig) = tup
        ds = tfm.design_size
        self.width = tfm.widths[w] *ds 
        self.height = tfm.heights[h] *ds
        self.depth = tfm.depths [d] * ds
        self.italic_correction = tfm.italic_corrections[i]*ds
        
        

class Tex_font_metric:
    """
    Bare bones wrapper around the TFM format.
    """
    
    
    def __init__ (self):
        pass
    
    def has_char (self, code):
        if code < self.start_code or code > self.end_code:
            return 0
        
        tup = self.chars[code - self.start_code]
        return tup[0] <> 0
    
    def get_char (self,code):
        tup = self.chars[code - self.start_code]
        return Char_metric (self, tup)

    def __str__ (self):
        return r"""#<TFM file
char: %d, %d
checksum: %d
design_size: %f
coding: %s>""" % (self.start_code, self.end_code,
        self.checksum, self.design_size, self.coding)



def read_tfm_file (fn):
    reader =Tfm_reader (open (fn).read ())
    return reader.get_tfm ()

if __name__=='__main__':
    t = read_tfm_file  (sys.argv[1])
    print t, t.design_size,  t.coding

