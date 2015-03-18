class ImporterController < ApplicationController
  def import
  end

  def export
    @as_article = params[:article].present?
    @article = Article.find(params[:article]) if @as_article
  end

  def download_file
    if params[:article].present?
      @articles = Article.where(:id => params[:article])
      @comments = @articles.first.comments
    else
      @articles = Article.all
      @comments = Comment.all
    end

    xlsx = Axlsx::Package.new
    wb = xlsx.workbook
    wb.add_worksheet(name: "Articles") do |sheet|
      sheet.add_row ["ID", "Title", "Body", "Created At", "Updated At"]
      @articles.each do |article|
        sheet.add_row [article.id, article.title, article.body, article.created_at, article.updated_at]
      end
    end
    wb.add_worksheet(name: "Comments") do |sheet|
      sheet.add_row ["ID", "Article ID", "Body", "Created At", "Updated At"]
      @comments.each do |comment|
        sheet.add_row [comment.id, comment.article_id, comment.body, comment.created_at, comment.updated_at]
      end
    end

    send_data xlsx.to_stream.read, type: "application/xlsx", filename: "complete.xlsx"
  end

  # POST
  def import_from_file
    raise 'Nothing to import' unless params[:sample].present?

    total_row = 0
    spreadsheet = open_spreadsheet(params[:sample])

    spreadsheet.sheets.each_with_index do |sheet, index|
      spreadsheet.default_sheet = spreadsheet.sheets[index]

      header = Array.new
      spreadsheet.row(1).each { |row| header << row.downcase.tr(' ', '_') }
      (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]
        new_row = eval("#{spreadsheet.default_sheet.singularize}").new(row)

        raise 'Failed to save, maybe invalid column' unless new_row.save!

        total_row += 1
      end
    end

    respond_to do |f|
      f.html { redirect_to articles_path, :notice => "Importing #{total_row} records successfully" }
    end
  end

  private
    def open_spreadsheet(file)
      case File.extname(file.original_filename)
        when '.csv' then Roo::Csv.new(file.path, nil, :ignore)
        when '.xls' then Roo::Excel.new(file.path, nil, :ignore)
        when '.xlsx' then Roo::Excelx.new(file.path, nil, :ignore)
        else raise "Unknown file type: #{file.original_filename}"
      end
    end
end
