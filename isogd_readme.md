Documentation for IsoGD baseline.
Baseline method:
  MFSK features -> Kmeans -> SVM
---
##Steps in detale:

####Step 1. Extract MFSK Features.
For both `train_list.txt` and `valid_list.txt` use `isogd/batch_MFSK_feature_isogd.m` program to extract and save MFSK for all videos.

####Step 2. Calculate Kmeans Center and Save Hists 
Excutes `joewan_upload_V2/joewan_code/iso_cal_center_and_get_hists.m` program to do all the works. It first randomly selects 20 videos for each class in train set, and uses features of these videos to calculate the center. When the center is ready, it will calculate and save the hist using the MFSK features of each video in both train set and validation set.

####Step 3. Use Lib-SVM to Train SVM Model and Predict the Label of Validation Hists. 
First scale both `train.hist` and `valid.hist` to range `[-1, 1]`, using command`svm-scale`. Then train svm with linear kernel type `svm-train -t 0`. At last, use trained model to generate labels for `valid.hist`.

####Step 4. Format svm prediction
You can use `isogd/evaluate.py` to do so.



