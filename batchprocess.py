import csv


inputfile = open('examples/chatgpt_labelling/output_tiktok_df_unlabelled_with context self generated.csv', 'r')
commentlines = inputfile.readlines()[1:]
batchNr = 1
counter = 0
print(len(commentlines))
while(counter < len(commentlines)):
    currentBatch = open('examples/insta_chatgpt_labelling/batch' + str(batchNr) + '.csv', 'w+')
    outputwriter = csv.writer(currentBatch)
    headerfields = ["id", "Comment", "Post id", "Post theme", "Background song/audio"]
    outputwriter.writerow(headerfields) 
    currentBatch.writelines(commentlines[counter:counter+10])
    batchNr += 1
    counter += 10
    currentBatch.close()