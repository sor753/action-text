class Post < ApplicationRecord
  has_rich_text :content

  validates :title, length: { maximum: 32 }, presence: true

  validate :validate_content_length, :validate_attachable_size, :validate_attachable_count
  #validate :メソッド名

  MAX_CONTENT_LENGTH = 50
  ONE_KB = 1024
  MB = 3
  MAX_ATTACHABLE_SIZE = MB * 1_000 * ONE_KB
  MAX_ATTACHABLE_COUNT = 4

  private

  #validateのメソッド定義
  def validate_content_length
    length = content.to_plain_text.length
    if length > MAX_CONTENT_LENGTH
      errors.add(
        :content,
        :too_long,
        max_content_length: MAX_CONTENT_LENGTH,
        length: length
      )
    end
  end

  def validate_attachable_size
    # if content.body.attachables.grep(ActiveStorage::Blob).first
    #   size = content.body.attachables.grep(ActiveStorage::Blob).first.byte_size
    #   if size > MAX_ATTACHABLE_SIZE
    #     errors.add(
    #       :content,
    #       :invalid,
    #       max_attachable_size: MAX_ATTACHABLE_SIZE,
    #       max_attachable_size_mb: MAX_ATTACHABLE_SIZE / 1000000,
    #       size: size
    #     )
    #   end
    # end
    content.body.attachables.grep(ActiveStorage::Blob).each do |attachable|
      if attachable.byte_size > MAX_ATTACHABLE_SIZE
        errors.add(
          :base,
          :contetn_attachment_byte_size_is_too_big,
          max_content_attachment_mega_byte_size: MB,
          bytes: attachable.byte_size,
          max_bytes: MAX_ATTACHABLE_SIZE
        )
      end
    end
  end

  def validate_attachable_count
    files = content.body.attachables.length
    if files > MAX_ATTACHABLE_COUNT
      errors.add(
        :base,
        :contetn_attachment_file_count_over,
        max_content_attachment_file_count: MAX_ATTACHABLE_COUNT,
        files: files
      )
    end
  end

end
