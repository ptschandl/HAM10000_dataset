# HAM 10000 Dataset Tools

<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons Lizenzvertrag" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/80x15.png" /></a>

This repository gives access to the tools created and used
for assembling the training dataset for the proposed HAM-10000
(*Human Against Machine with 10000 training images*)
study, which is planned to extend part 3 of the ISIC 2018
challenge. The training dataset is accessible through the [ISIC 2018 challenge](http://workshop2018.isic-archive.com/#challenge), and will perpetually
be available in the [ISIC-archive](https://isic-archive.com/#images)
thereafter.

<hr>

## Extract

Following technique was used to leverage image data
from PowerPoint slides, by extracting and ordering them with unique identifiers:
- [`extract/extract_pptx.py`](extract/extract_pptx.py): Extracts images and
corresponding IDs from \*.pptx Presentation slides

<hr>

## Filter

To more efficiently order large image sets of containing non-annotated overview
(_clinic_), closeup (_macro_) and dermatoscopic (_dsc_) images, we fine-tuned a
neural network to distinguish between those types automatically.

#### 1. Annotation
- [`filter/filter_annotation.py`](filter/filter_annotation.py): An
OpenCV based script to quickly annotate images within a subfolder into
different image types. Results are stored in a CSV-file with the option to
abort-and-resume annotation.


#### 2. Training
Training was performed in *Caffe / DIGITS* abstracting away many training
variables. We gained 1501 annotated images with the tool above and proceeded
to training: GoogLeNet pretrained on ImageNet (taken from the NVIDIA DIGITS 5
Model Store) was fine-tuned on three classes for 20 epochs, landing at a final
top-1 accuracy on the test-set of 98.68% (one _dermatoscopic_ image classified
as _macro_). The trained model files are provided in `./classify/caffe_model/*`

#### 3. Inference

- [`filter/filter_inference.py`](filter/filter_inference.py): Classifies all
jpg-files in a subfolder and writes image type prediction to a csv file. (Adapted
  code from the [NVIDIA GitHub repository](https://github.com/NVIDIA/DIGITS/tree/master/examples/classification))

<hr>

## Unify

Pathologic diagnoses in clinical practice are often non-standardized and
verbose. The notebook below depicts our boilerplate used on
different datasets to merge raw string data into a clean set of classes.

- [`unify/unify_diagnoses.ipynb`](unify/unify_diagnoses.ipynb) uses the *pandas*
library to clean and unify diagnosis texts of dermatologic lesions into a
confined set of diagnoses other or ambiguous classes. <br>
**Note:** The notebook contains only a subset of example terms for display purposes,
as regular expressions are optimized to fit a given dataset. Therefore, most
commonly the ones given will _not_ be ready to be applied on a new set out of the box.
Importantly, also the _order_ of relabeling diagnoses matter, so we highly
recommend manual checkup of relabeled diagnoses and stepwise iteration when
applying to a new dataset.

<hr>

## Standardise

To normalise image format without squeezing, one Bash/ImageMagick command was applied
to final images before data submission to the archive:

`find . -type f \( -iname \*.jpg -o -iname \*.jpeg -o -iname \*.tiff -o -iname \*.tif \) -print0 | xargs -0 -n1 mogrify -strip -rotate "90<" -resize "600x450^" -gravity center -crop 600x450+0+0 -density 72 -units PixelsPerInch -format jpg -quality 100`

<hr>
